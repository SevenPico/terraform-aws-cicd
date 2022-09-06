import boto3
import json
import logging
import requests

import config

config = config.Config()
session = boto3.Session()

def lambda_handler(event, context):
    print(f"Lambda Input Event: {event}")
    print(f"Lambda Input Context: {context}")



# WEBHOOK_URL = 'https://hooks.slack.com/services/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'

# def main():
#     artifact_info(type='ecr', uri='some-uri-here')
#     # artifact_info(type='s3', uri='some-other-uri-here')


# def artifact_info(type, uri):
#     request = {
#         "blocks": [
#             {
#                 "type": "header",
#                 "text": {
#                     "type": "plain_text",
#                     "text": f"Build Artifact Published",
#                     "emoji": True
#                 }
#             },
#             {
#                 "type": "section",
#                 "fields": [
#                     {
#                         "type": "mrkdwn",
#                         "text": f"*Type:*\n{type.upper()}"
#                     },
#                     {
#                         "type": "mrkdwn",
#                         "text": f"*URI:*\n{uri}"
#                     },
#                 ]
#             },
# 	    ]
#     }

#     response = requests.post(WEBHOOK_URL, json = request)
#     print(response)


# def deployment_info(deployment_id, target_name, source):
#     return {
#   	"text": f"Approval Required for Deployment to {target_name}",
# 	"blocks": [
# 		{
# 			"type": "header",
# 			"text": {
# 				"type": "plain_text",
# 				"text": "New request",
# 				"emoji": True
# 			}
# 		},
# 		{
# 			"type": "section",
# 			"fields": [
# 				{
# 					"type": "mrkdwn",
# 					"text": "*Type:*\nPaid Time Off"
# 				},
# 				{
# 					"type": "mrkdwn",
# 					"text": "*Created by:*\n<example.com|Fred Enriquez>"
# 				}
# 			]
# 		},
# 		{
# 			"type": "section",
# 			"fields": [
# 				{
# 					"type": "mrkdwn",
# 					"text": "*When:*\nAug 10 - Aug 13"
# 				}
# 			]
# 		},
# 		{
# 			"type": "actions",
# 			"elements": [
# 				{
# 					"type": "button",
# 					"text": {
# 						"type": "plain_text",
# 						"emoji": True,
# 						"text": "Approve"
# 					},
# 					"style": "primary",
# 					"value": "click_me_123"
# 				},
# 				{
# 					"type": "button",
# 					"text": {
# 						"type": "plain_text",
# 						"emoji": True,
# 						"text": "Reject"
# 					},
# 					"style": "danger",
# 					"value": "click_me_123"
# 				}
# 			]
# 		}
# 	]
# }

# # def deployment_approval(target_name, source):
# #     return {
# #   	"text": f"Approval Required for Deployment to {target_name}",
# # 	"blocks": [
# # 		{
# # 			"type": "header",
# # 			"text": {
# # 				"type": "plain_text",
# # 				"text": "New request",
# # 				"emoji": True
# # 			}
# # 		},
# # 		{
# # 			"type": "section",
# # 			"fields": [
# # 				{
# # 					"type": "mrkdwn",
# # 					"text": "*Type:*\nPaid Time Off"
# # 				},
# # 				{
# # 					"type": "mrkdwn",
# # 					"text": "*Created by:*\n<example.com|Fred Enriquez>"
# # 				}
# # 			]
# # 		},
# # 		{
# # 			"type": "section",
# # 			"fields": [
# # 				{
# # 					"type": "mrkdwn",
# # 					"text": "*When:*\nAug 10 - Aug 13"
# # 				}
# # 			]
# # 		},
# # 		{
# # 			"type": "actions",
# # 			"elements": [
# # 				{
# # 					"type": "button",
# # 					"text": {
# # 						"type": "plain_text",
# # 						"emoji": True,
# # 						"text": "Approve"
# # 					},
# # 					"style": "primary",
# # 					"value": "click_me_123"
# # 				},
# # 				{
# # 					"type": "button",
# # 					"text": {
# # 						"type": "plain_text",
# # 						"emoji": True,
# # 						"text": "Reject"
# # 					},
# # 					"style": "danger",
# # 					"value": "click_me_123"
# # 				}
# # 			]
# # 		}
# # 	]
# # }


# # request = {
# #     "text": "Danny Torrence left a 1 star review for your property.",
# #     "blocks": [
# #     	{
# #     		"type": "section",
# #     		"text": {
# #     			"type": "mrkdwn",
# #     			"text": "Danny Torrence left the following review for your property:"
# #     		}
# #     	},
# #     	{
# #     		"type": "section",
# #     		"block_id": "section567",
# #     		"text": {
# #     			"type": "mrkdwn",
# #     			"text": "<https://example.com|Overlook Hotel> \n :star: \n Doors had too many axe holes, guest in room 237 was far too rowdy, whole place felt stuck in the 1920s."
# #     		},
# #     		"accessory": {
# #     			"type": "image",
# #     			"image_url": "https://is5-ssl.mzstatic.com/image/thumb/Purple3/v4/d3/72/5c/d3725c8f-c642-5d69-1904-aa36e4297885/source/256x256bb.jpg",
# #     			"alt_text": "Haunted hotel image"
# #     		}
# #     	},
# #     	{
# #     		"type": "section",
# #     		"block_id": "section789",
# #     		"fields": [
# #     			{
# #     				"type": "mrkdwn",
# #     				"text": "*Average Rating*\n1.0"
# #     			}
# #     		]
# #     	}
# #     ]
# # }

# main()
