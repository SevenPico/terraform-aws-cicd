import json
import urllib3
import os
import re
import boto3

import config

config = config.Config()
http = urllib3.PoolManager()
session = boto3.Session()

def get_slack_token(secret_arn):
    client = session.client('secretsmanager')
    response = client.get_secret_value(
        SecretId = secret_arn
    )
    return response['SecretString']

SLACK_URL = 'https://slack.com/api'
SLACK_TOKEN = get_slack_token(config.slack_secret_arn)

def lambda_handler(event, context):
    print(f'Lambda Input Event: {event}')
    print(f'Lambda Input Context: {context}')

    e = json.loads(event['Records'][0]['Sns']['Message'])
    print(f'Event: {e}')

    type = e['type'].upper()
    uri = e['uri']

    if type == 'ECR':
        artifact, version = e['repository_name'], e['tag']
    elif type == 'S3':
        artifact, version = get_artifact_name_version(os.path.basename(e['key']), config.artifact_regex)
    else:
        artifact, version  = '', ''

    msg = {
        'blocks': [
            {
                'type': 'section',
                'text': { 'type': 'plain_text', 'text': 'Build Artifact Published' },
            },
            {
                'type': 'context',
                'elements': [
                    {'type': 'plain_text', 'text': f'Type: {type}' },
                    {'type': 'plain_text', 'text': uri},
                    {'type': 'plain_text', 'text': f'Artifact: {artifact}' },
                    {'type': 'plain_text', 'text': f'Version: {version}'},
                ]
            },
        ]
    }

    print('Slack Message:', msg)

    for channel_id in config.slack_channel_ids:
        msg['channel'] = channel_id
        response = http.request('POST', f'{SLACK_URL}/chat.postMessage',
            body = json.dumps(msg).encode('utf-8'),
            headers = {
                'Content-type': 'application/json; charset=utf-8',
                'Authorization': f'Bearer {SLACK_TOKEN}',
            },
        )
        print('Slack Response:', response)


def get_artifact_name_version(artifact, artifact_re):
    match = re.search(artifact_re, artifact)
    return(match.group('name'), match.group('version'))
