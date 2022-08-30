# ------------------------------------------------------------------------------
# Deployment Targets Map Merge
# ------------------------------------------------------------------------------
locals {
  targets = merge(
    { for k, v in var.ecs_targets : "ecs/${k}" => v.image_uri },
    # FIXME
  )
}


# ------------------------------------------------------------------------------
# ECS Target Pipelines
# ------------------------------------------------------------------------------
module "ecs_pipeline" {
  source  = "./modules/ecs-pipeline"
  context = module.context.self

  for_each   = var.ecs_targets
  attributes = [each.key]

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
