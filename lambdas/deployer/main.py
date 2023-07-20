import boto3
import json
import logging
import pathlib
import zipfile
import tempfile
import os
import urllib.parse
from mimetypes import guess_type
from io import BytesIO

import config

config = config.Config()
session = boto3.Session()


def lambda_handler(event, context):
    print(f'Lambda Input Event: {event}')
    print(f'Lambda Input Context: {context}')

    try:
        e = json.loads(event['Records'][0]['Sns']['Message'])  # handle sns trigger
    except:
        e = event

    print(f'Source Event: {e}')

    if e['type'] in ['ecr', 's3', 'cloudformation']:
        trigger_by_uri(e['uri'])

    if e['type'] in ['ssm']:
        name = e['parameter_name'].removeprefix("/version/")
        trigger_by_name(name)


def trigger_by_name(name):
    for target_name, source_uri in get_target_source_map().items():
        if name != target_name:
            continue

        type = target_name.split('/')[-2]  # {id}/{type}/{name}

        if type == 'ecs':
            trigger_ecs_pipeline(target_name, source_uri)
        elif type == 's3':
            trigger_s3_pipeline(target_name, source_uri)
        elif type == 'cloudformation':
            trigger_cf_pipeline(target_name, source_uri)
        else:
            logging.warning(f"Unsupported event type '{type} for '{target_name}' {source_uri}")


def trigger_by_uri(uri):
    for target_name, source_uri in get_target_source_map().items():
        if uri != source_uri:
            continue
        trigger_by_name(target_name)


def chunk_list(l, n):
    for i in range(0, len(l), n):
        yield l[i:i + n]


def get_target_source_map():
    ssm = session.client('ssm')

    target_source_map = {}

    N = 10  # get_parameters needs to be called in batches <= 10
    for chunk in chunk_list(config.target_names, N):
        response = ssm.get_parameters(Names=[f'/version/{name}' for name in chunk], WithDecryption=True)

        for p in response['InvalidParameters']:
            logging.error(f"SSM Parameter '{p}' not found.")

        for p in response['Parameters']:
            name = p['Name'].removeprefix("/version/")
            target_source_map[name] = p['Value'].strip()

            print(f"{p['Name']} = {p['Value']}")

    return target_source_map


def trigger_ecs_pipeline(target_name, image_uri):
    print(f"Triggering '{target_name}' ECS pipeline with {image_uri}")

    s3 = boto3.client('s3')
    image_detail = [{
        'name': target_name.split('/')[-1],  # {id}/{type}/{name}
        'imageUri': image_uri
    }]

    zip_file_object = BytesIO()
    with zipfile.ZipFile(zip_file_object, mode='w', compression=zipfile.ZIP_DEFLATED) as zf:
        zf.writestr('imagedefinitions.json', json.dumps(image_detail).encode('UTF'))
        zf.close()
        s3.put_object(
            Bucket=config.deployer_artifacts_bucket_id,
            Key=f'{target_name}.zip',
            Body=zip_file_object.getvalue()
        )


def trigger_s3_pipeline(target_name, object_uri):
    print(f"Triggering '{target_name}' S3 pipeline with {object_uri}")

    suffix = pathlib.Path(object_uri).suffix

    s3 = session.client('s3')
    s3.copy_object(
        Bucket=config.deployer_artifacts_bucket_id,
        Key=f'{target_name}{suffix}',
        CopySource=object_uri,
    )


def trigger_cf_pipeline(target_name, object_uri):
    print(f"Triggering '{target_name}' Cloudformation pipeline with {object_uri}")

    s3 = session.client('s3')
    bucket_name = object_uri.split('/')[0]
    object_key = object_uri.split('/', 1)[1]
    response = s3.get_object(Bucket=bucket_name, Key=object_key)

    print(f"Bucket: {bucket_name}, Key: {object_key}")

    with tempfile.TemporaryDirectory() as tmpdir:
        zip_file_path = f"{tmpdir}/stack.zip"
        target_dir = f"{tmpdir}/{target_name}"

        # Save the ZIP file to a temporary location
        with open(zip_file_path, 'wb') as f:
            f.write(response['Body'].read())

        # Extract the ZIP file
        with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
            zip_ref.extractall(target_dir)

        # Upload the extracted files to the deployer_artifacts_bucket_id
        for root, _, files in os.walk(target_dir):
            for file in files:
                source_path = os.path.join(root, file)
                target_path = os.path.relpath(source_path, target_dir)
                s3.upload_file(source_path, config.deployer_artifacts_bucket_id, f"{target_name}/{target_path}")

    print("Upload complete!")
