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
##  ./notifier-sns.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Artifact Update SNS Topic
# ------------------------------------------------------------------------------
module "notifier_sns" {
  source  = "SevenPico/sns/aws"
  version = "2.0.0"
  context = module.context.self

  kms_master_key_id = ""
  pub_principals    = {}
  sub_principals    = {}
}


# ------------------------------------------------------------------------------
# CodePipeline Event Rule
# ------------------------------------------------------------------------------
module "codepipeline_event" {
  source  = "SevenPico/events/aws//cloudwatch-event"
  version = "1.0.0"
  context = module.context.self

  description = "CodePipeline Events"
  target_arn  = module.notifier_sns.topic_arn

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = concat(
        [for p in module.s3_pipeline : p.id],
        [for p in module.ecs_pipeline : p.id],
      )
    }
  })
}
