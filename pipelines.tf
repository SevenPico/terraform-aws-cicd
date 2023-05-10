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
##  ./pipelines.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# Deployment Targets Map Merge
# ------------------------------------------------------------------------------
locals {
  targets = merge(
    { for k, v in var.ecs_targets : "${module.context.id}/ecs/${k}" => v.image_uri },
    { for k, v in var.s3_targets : "${module.context.id}/s3/${k}" => "${v.source_s3_bucket_id}/${v.source_s3_object_key}" },
  )

  ecs_target_version_ssm_parameter_names_map = module.context.enabled ? { for k, v in var.ecs_targets : k => aws_ssm_parameter.target_source["${module.context.id}/ecs/${k}"].name } : {}
  s3_target_version_ssm_parameter_names_map  = module.context.enabled ? { for k, v in var.s3_targets : k => aws_ssm_parameter.target_source["${module.context.id}/s3/${k}"].name } : {}
}


# ------------------------------------------------------------------------------
# ECS Target Pipelines
# ------------------------------------------------------------------------------
module "ecs_pipeline" {
  source  = "./modules/ecs-pipeline"
  context = module.context.self

  for_each   = var.ecs_targets
  attributes = ["ecs", each.key]

  artifact_store_kms_key_arn     = "" # FIXME which IAM permissions required to use this? module.kms_key.key_arn
  artifact_store_s3_bucket_id    = module.deployer_artifacts_bucket.bucket_id
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
  ecs_cluster_name               = each.value.ecs_cluster_name
  ecs_service_name               = each.value.ecs_service_name
  ecs_deployment_timeout         = var.ecs_deployment_timeout
  image_detail_s3_bucket_id      = module.deployer_artifacts_bucket.bucket_id
  image_detail_s3_object_key     = "${module.context.id}/ecs/${each.key}.zip"
}


# ------------------------------------------------------------------------------
# S3 Target Pipelines
# ------------------------------------------------------------------------------
module "s3_pipeline" {
  source  = "./modules/s3-pipeline"
  context = module.context.self

  for_each   = var.s3_targets
  attributes = ["s3", each.key]

  artifact_store_kms_key_arn     = "" # FIXME which IAM permissions required to use this? module.kms_key.key_arn
  artifact_store_s3_bucket_id    = module.deployer_artifacts_bucket.bucket_id
  cloudwatch_log_expiration_days = 90
  source_s3_bucket_id            = each.value.source_s3_bucket_id
  source_s3_object_key           = each.value.source_s3_object_key
  target_s3_bucket_id            = each.value.target_s3_bucket_id

  pre_deploy_enabled               = (each.value.pre_deploy != null)
  pre_deploy_buildspec             = try(each.value.pre_deploy.buildspec, "deployspec.yml")
  pre_deploy_policy_docs           = try(each.value.pre_deploy.policy_docs, [])
  pre_deploy_environment_variables = try(each.value.pre_deploy.env_vars, [])
}


# ------------------------------------------------------------------------------
# SSM Parameter for Target Sources
# ------------------------------------------------------------------------------
resource "aws_ssm_parameter" "target_source" {
  for_each = module.context.enabled ? local.targets : {}

  allowed_pattern = null # TODO
  data_type       = "text"
  description     = "Artifact Source '${each.key}'"
  insecure_value  = null
  key_id          = module.kms_key.key_arn
  name            = "/version/${each.key}"
  overwrite       = var.overwrite_ssm_parameters
  tags            = module.context.tags
  tier            = "Standard"
  type            = "SecureString"
  value           = each.value

  lifecycle {
    ignore_changes = [value, insecure_value]
  }
}


# ------------------------------------------------------------------------------
# KMS Key
# ------------------------------------------------------------------------------
module "kms_key" {
  source  = "SevenPicoForks/kms-key/aws"
  version = "2.0.0"
  context = module.context.self
  enabled = module.context.enabled && var.create_kms_key

  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  deletion_window_in_days  = var.kms_key_deletion_window_in_days
  description              = "KMS key for CI/CD ${module.context.id}"
  enable_key_rotation      = var.kms_key_enable_key_rotation
  key_usage                = "ENCRYPT_DECRYPT"
  multi_region             = false
}


# ------------------------------------------------------------------------------
# Lambda Event Trigger on Target Source Change
# ------------------------------------------------------------------------------
module "ssm_target_source_update_event" {
  source     = "SevenPico/events/aws//cloudwatch-event"
  version    = "1.0.0"
  context    = module.context.self
  attributes = ["target-source-update"]

  description = "SSM Target Source Update Event"
  target_arn  = module.deployer_lambda.arn

  event_pattern = jsonencode({
    source      = ["aws.ssm"]
    detail-type = ["Parameter Store Change"]
    detail = {
      name = [for p in aws_ssm_parameter.target_source : p.name],
      operation = [
        "Update",
        "Create",
        "LabelParameterVersion",
      ]
    }
  })

  transformer = {
    template = <<EOF
    {
      "type": "ssm",
      "action": "update",
      "parameter_name": "<parameter_name>"
    }
    EOF
    paths = {
      parameter_name = "$.detail.name"
    }
  }
}
