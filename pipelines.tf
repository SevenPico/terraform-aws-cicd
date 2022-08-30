# ------------------------------------------------------------------------------
# Deployment Targets Map Merge
# ------------------------------------------------------------------------------
locals {
  targets = merge(
    { for k, v in var.ecs_targets : "ecs/${k}" => v.image_uri },
    { for k, v in var.s3_targets : "s3/${k}" => "${v.source_s3_bucket_id}/${v.source_s3_object_key}" },
  )
}


# ------------------------------------------------------------------------------
# ECS Target Pipelines
# ------------------------------------------------------------------------------
module "ecs_pipeline" {
  source  = "./modules/ecs-pipeline"
  context = module.context.self

  for_each   = var.ecs_targets
  attributes = ["ecs", each.key]

  artifact_store_kms_key_id      = ""
  artifact_store_s3_bucket_id    = module.deployer_artifacts_bucket.bucket_id
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
  ecs_cluster_name               = each.value.ecs_cluster_name
  ecs_service_name               = each.value.ecs_service_name
  ecs_deployment_timeout         = var.ecs_deployment_timeout
  image_detail_s3_bucket_id      = module.deployer_artifacts_bucket.bucket_id
  image_detail_s3_object_key     = "ecs/${each.key}.zip"
}


# ------------------------------------------------------------------------------
# S3 Target Pipelines
# ------------------------------------------------------------------------------
module "s3_pipeline" {
  source  = "./modules/s3-pipeline"
  context = module.context.self

  for_each   = var.s3_targets
  attributes = ["s3", each.key]

  artifact_store_kms_key_id      = ""
  artifact_store_s3_bucket_id    = module.deployer_artifacts_bucket.bucket_id
  cloudwatch_log_expiration_days = 90
  source_s3_bucket_id            = module.deployer_artifacts_bucket.bucket_id
  source_s3_object_key           = "s3/${each.key}.zip"
  target_s3_bucket_id            = each.value.target_s3_bucket_id

  pre_deploy_enabled               = (each.value.pre_deploy != null)
  pre_deploy_buildspec             = try(each.value.pre_deploy.buildspec, "deployspec.yml")
  pre_deploy_extra_permissions     = try(each.value.pre_deploy.permissions, [])
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
  insecure_value  = each.value
  key_id          = null
  name            = "/${each.key}"
  overwrite       = !var.ignore_target_source_changes
  tags            = module.context.tags
  tier            = "Standard"
  type            = "String"
  value           = null
}


# ------------------------------------------------------------------------------
# Lambda Event Trigger on Target Source Change
# ------------------------------------------------------------------------------
module "ssm_target_source_update_event" {
  source     = "app.terraform.io/SevenPico/events/aws//cloudwatch-event"
  version    = "0.0.2"
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
