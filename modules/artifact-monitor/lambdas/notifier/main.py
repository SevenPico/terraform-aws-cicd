import json
import urllib3

import config

config = config.Config()


def lambda_handler(event, context):
    print(f"Lambda Input Event: {event}")
    print(f"Lambda Input Context: {context}")

    http = urllib3.PoolManager()

    e = json.loads(event["Records"][0]["Sns"]["Message"])
    print(f"Event: {e}")

    request = {
        "blocks": [
            {"type": "divider"},
            {
                "type": "section",
                "text": {
                    "type": "plain_text",
                    "text": "Build Artifact Published",
                    "emoji": True,
                },
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "plain_text",
                        "text": f"Type: {e['type'].upper()}",
                        "emoji": True,
                    },
                    {"type": "plain_text", "text": f"{e['uri']}", "emoji": True},
                ],
            },
        ]
    }

    if e["type"] == "ecr":
        request["blocks"] += [
            {
                "type": "context",
                "elements": [
                    {
                        "type": "plain_text",
                        "text": f"Repository: {e['repository_name']}",
                        "emoji": True,
                    },
                    {"type": "plain_text", "text": f"Tag: {e['tag']}", "emoji": True},
                ],
            },
        ]

    if e["type"] == "s3":
        request["blocks"] += [
            {
                "type": "context",
                "elements": [
                    {
                        "type": "plain_text",
                        "text": f"Bucket: {e['bucket_id']}",
                        "emoji": True,
                    },
                    {"type": "plain_text", "text": f"Key: {e['key']}", "emoji": True},
                ],
            },
        ]

    print("Slack Request:", request)
    response = http.request("POST", config.slack_webhook_url, body=json.dumps(request))
    print("Slack Response:", response)
