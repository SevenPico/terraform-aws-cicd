import json
import urllib3
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

    execution_id = e['detail']['execution-id']
    state        = e['detail']['state']

    context = {
        'project': config.project,
        'pipeline': e['detail']['pipeline'],
    }

    for channel_id in config.slack_channel_ids:
        if state == 'STARTED':
            post_start_message(execution_id, channel_id, context)
        elif state == 'SUCCEEDED':
            post_update_message(execution_id, channel_id, state, 'rocket')
        elif state == 'FAILED':
            post_update_message(execution_id, channel_id, state, 'x')
        else:
            post_update_message(execution_id, channel_id, state)


def post_message(msg, channel_id, msg_id=None, thread_ts=None):
    msg['channel'] = channel_id

    if thread_ts is not None:
        msg['thread_ts'] = thread_ts

    if msg_id is not None:
        msg.setdefault('blocks', [])
        msg['blocks'].append({
            'type': 'context',
            'elements': [{
                'type': 'plain_text',
                'text': f'id: {msg_id}',
            }]
        })

    # TODO - check response
    _ = http.request('POST', f'{SLACK_URL}/chat.postMessage',
        body=json.dumps(msg).encode('utf-8'),
        headers={
            'Content-type': 'application/json; charset=utf-8',
            'Authorization': f'Bearer {SLACK_TOKEN}',
        },
    )


def get_message_by_id(msg_id, channel_id):
    response = http.request('GET', f'{SLACK_URL}/conversations.history?channel={channel_id}',
        headers={ 'Authorization': f'Bearer {SLACK_TOKEN}' })

    messages = json.loads(response.data).get('messages') or []
    for m in messages:
        try:
            context = m['blocks'][-1]['elements'][0]['text']
        except:
            context = ''
        if msg_id in context:
            return m['ts']
    return None


def post_start_message(msg_id, channel_id, context={}):
    msg = {
        'text': 'Deployment Started',
        'blocks': [
            {
                'type': 'section',
                'text': {
                    'type': 'plain_text',
                    'text': f'Deployment Started',
                    'emoji': True,
                }
            },
            {
                'type': 'section',
                'text': {
                    'type': 'mrkdwn',
                    'text': '\n'.join([f'{key}: `{value}`' for key, value in context.items()]),
                }
            },
        ]
    }
    post_message(msg, channel_id=channel_id, msg_id=msg_id, thread_ts=None)


def post_update_message(msg_id, channel_id, state, reaction_name=None):
    msg = {
        'text': f'Deployment {state}',
        'blocks': [{
            'type': 'section',
            'text': {
                'type': 'plain_text',
                'text': f'Deployment {state.title()}' if reaction_name is None else f':{reaction_name}: Deployment {state.title()}'
            },
        }]
    }
    timestamp = get_message_by_id(msg_id, channel_id)
    post_message(msg, channel_id=channel_id, msg_id=None, thread_ts=timestamp)
    if reaction_name is not None:
        add_reaction(timestamp, channel_id, reaction_name)


def add_reaction(timestamp, channel_id, name):
    # TODO - check response
    _ = http.request('POST', f'{SLACK_URL}/reactions.add',
        headers = {'Authorization': f'Bearer {SLACK_TOKEN}'},
        fields = {'channel': channel_id, 'timestamp': timestamp, 'name': name},
    )

