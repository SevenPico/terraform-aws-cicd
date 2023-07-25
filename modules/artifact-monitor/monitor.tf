## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./modules/artifact-monitor/monitor.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Artifact Update SNS Topic
# ------------------------------------------------------------------------------
module "sns_topic" {
  source  = "SevenPico/sns/aws"
  version = "2.0.2"
  context = module.context.self

  kms_master_key_id = ""
  pub_principals    = var.sns_pub_principals
  sub_principals    = var.sns_sub_principals
}


# ------------------------------------------------------------------------------
# ECR Image Push Event Rule
# ------------------------------------------------------------------------------
module "ecr_event" {
  source  = "SevenPico/events/aws//cloudwatch-event"
  version = "1.0.0"
  context = module.context.self

  for_each = var.ecr_repository_url_map
  name     = each.key

  description = "ECR Push Event to ${each.key} repository."
  target_arn  = module.sns_topic.topic_arn

  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      result          = ["SUCCESS"]
      repository-name = [each.key]
    }
  })

  transformer = {
    template = <<EOF
    {
      "type": "ecr",
      "action": "update",
      "repository_name": "${each.key}",
      "repository_url": "${each.value}",
      "uri": "${each.value}:<tag>",
      "tag": <tag>
    }
    EOF
    paths = {
      tag = "$.detail.image-tag"
    }
  }
}


# ------------------------------------------------------------------------------
# S3 Object Update Event Rule
# ------------------------------------------------------------------------------
module "s3_event" {
  source          = "SevenPico/events/aws//cloudwatch-event"
  version         = "1.0.0"
  context         = module.context.self
  id_length_limit = 128

  for_each = toset(var.s3_bucket_ids)
  name     = each.key

  description = "S3 Object Created in s3://${each.key}"
  target_arn  = module.sns_topic.topic_arn

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail-type = ["Object Created"]
    detail = {
      bucket = {
        name = [each.key]
      }
    }
  })

  transformer = {
    template = <<EOF
    {
      "type": "s3",
      "action": "update",
      "bucket_id": <bucket_id>,
      "key": <key>,
      "uri": "<bucket_id>/<key>"
    }
    EOF
    paths = {
      bucket_id = "$.detail.bucket.name"
      key       = "$.detail.object.key"
    }
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  for_each = toset(module.context.self.enabled ? var.s3_bucket_ids : [])

  bucket      = each.key
  eventbridge = true
}
