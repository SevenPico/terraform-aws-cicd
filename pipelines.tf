# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
locals {
  targets = merge(
    { for k, v in var.ecs_targets : "ecs/${k}" => v.image_uri },
  )
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "ecs_pipeline" {
  source  = "./ecs-pipeline"
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

resource "aws_ssm_parameter" "target_source" {
  for_each = module.context.enabled ? local.targets : {}

  allowed_pattern = null # TODO
  data_type       = "text"
  description     = "Artifact Source '${each.key}'"
  insecure_value  = each.value
  key_id          = null
  name            = "/${each.key}"
  overwrite       = true
  tags            = module.context.tags
  tier            = "Standard"
  type            = "String"
  value           = null
}
