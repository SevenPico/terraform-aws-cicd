import boto3
import json
import logging
import pathlib
import zipfile
from io import BytesIO

import config

config = config.Config()
session = boto3.Session()

def lambda_handler(event, context):
    print(f'Lambda Input Event: {event}')
    print(f'Lambda Input Context: {context}')

    try:
        e = json.loads(event['Records'][0]['Sns']['Message']) # handle sns trigger
    except:
        e = event

    #e = { 'type': 'ecr', 'uri': '249974707517.dkr.ecr.us-east-1.amazonaws.com/foo:alpha' }
    #e = { 'type': 'ssm', 'action': 'update', 'parameter_name': '/ecs/foo'}

    print(f'Source Event: {e}')

    if e['type'] in ['ecr', 's3']:
        trigger_by_uri(e['uri'])

    if e['type'] in ['ssm']:
        trigger_by_name(e['parameter_name'][1:])


def trigger_by_name(name):
    for target_name, source_uri in get_target_source_map().items():
        if name != target_name:
            continue

        type = target_name.split('/')[0]

        if type == 'ecs':
            trigger_ecs_pipeline(target_name, source_uri)
        elif type == 's3':
            trigger_s3_pipeline(target_name, source_uri)
        else:
            logging.warning(f"Unsupported event type '{type} for '{target_name}' {source_uri}")


def trigger_by_uri(uri):
    for target_name, source_uri in get_target_source_map().items():
        if uri != source_uri:
            continue
        trigger_by_name(target_name)


def get_target_source_map():
    ssm = session.client('ssm')
    response = ssm.get_parameters(Names = [f'/{name}' for name in config.target_names])

    for p in response['Parameters']:
        print(f"{p['Name']} = {p['Value']}")

    for p in response['InvalidParameters']:
        logging.error(f"SSM Parameter '{p}' not found.")

    return { p['Name'][1:] : p['Value'].strip() for p in response['Parameters'] }



def trigger_ecs_pipeline(target_name, image_uri):
    print(f"Triggering '{target_name}' ECS pipeline with {image_uri}")

    s3 = boto3.client('s3')
    image_detail = [{ 'name': target_name.split('/')[-1], 'imageUri': image_uri }]

    zip_file_object = BytesIO()
    with zipfile.ZipFile(zip_file_object, mode='w', compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr('imagedefinitions.json', json.dumps(image_detail).encode('UTF'))
        zf.close()
        s3.put_object(
            Bucket = config.deployer_artifacts_bucket_id,
            Key    = f'{target_name}.zip',
            Body   = zip_file_object.getvalue()
        )


def trigger_s3_pipeline(target_name, object_uri):
    print(f"Triggering '{target_name}' S3 pipeline with {object_uri}")

    suffix = pathlib.Path(object_uri).suffix

    s3 = session.client('s3')
    s3.copy_object(
        Bucket     = config.deployer_artifacts_bucket_id,
        Key        = f'{target_name}{suffix}',
        CopySource = object_uri,
    )

#lambda_handler(None, None)