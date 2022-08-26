import boto3
import json
import logging
import pathlib

import config

logging.basicConfig(level=logging.INFO)

config = config.Config()
session = boto3.Session()

def lambda_handler(event, context):
    logging.info(f'Lambda Input Event: {event}')
    logging.info(f'Lambda Input Context: {context}')

    e = json.loads(event['Records'][0]['Sns']['Message'])
    #e = {'type': 's3', 'uri': 's3://eg-test-artifacts/sites/oof/oof-test.zip'}
    #e = {'type': 's3', 'uri': 's3://eg-test-artifacts/sites/bar/bar-test.zip'}
    #e = {'type': 'ecr', 'uri': '249974707517.dkr.ecr.us-east-1.amazonaws.com/foo:latest'}
    logging.info(f'Source Event: {e}')

    for target_name, source_uri in get_target_source_map().items():
        if e['uri'] != source_uri:
            continue
        elif e['type'] == 'ecr':
            logging.info(f"Triggering '{target_name}' ECS pipeline with {source_uri}")
            trigger_ecs_pipeline(target_name, source_uri)
        elif e['type'] == 's3':
            logging.info(f"Triggering '{target_name}' S3 pipeline with {source_uri}")
            trigger_s3_pipeline(target_name, source_uri)
        else:
            logging.warning(f"Unsupported event type '{e['type']} for '{target_name}' {source_uri}")


def get_target_source_map():
    ssm = session.client('ssm')
    response = ssm.get_parameters(Names = config.target_names)

    for p in response['Parameters']:
        logging.info(f"{p['Name']} = {p['Value']}")

    for p in response['InvalidParameters']:
        logging.error(f"SSM Parameter '{p}' not found.")

    return { p['Name'] : p['Value'].strip() for p in response['Parameters'] }


def trigger_ecs_pipeline(target_name, image_uri):
    s3 = boto3.client('s3')
    image_detail = [{ 'name': target_name, 'imageUri': image_uri }]

    s3.put_object(
        Bucket = config.artifact_bucket_id,
        Key    = f'{target_name}.json',
        Body   = json.dumps(image_detail),
    )


def trigger_s3_pipeline(target_name, object_uri):
    suffix = pathlib.Path(object_uri).suffix

    s3 = session.client('s3')
    s3.copy_object(
        Bucket     = config.artifact_bucket_id,
        Key        = f'{target_name}{suffix}',
        CopySource = object_uri,
    )
