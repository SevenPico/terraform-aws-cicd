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
                    "text": "Deployment Event",
                    "emoji": True,
                },
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "plain_text",
                        "text": f"State: {e['detail']['state']}",
                        "emoji": True,
                    },
                    {
                        "type": "plain_text",
                        "text": f"execution-id: {e['detail']['execution-id']}",
                        "emoji": True,
                    },
                ],
            },
        ]
    }

    print("Slack Request:", request)
    response = http.request("POST", config.slack_webhook_url, body=json.dumps(request))

    print("Slack Response:")
    print(response.status)
    print(response.headers)
    print(response.data)
