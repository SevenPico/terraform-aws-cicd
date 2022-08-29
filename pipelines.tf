# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "ecs_pipeline" {
  source  = "./ecs-pipeline"
  context = module.context.self

  for_each   = var.ecs_targets
  attributes = [each.key]

  artifact_store_kms_key_id      = ""
  artifact_store_s3_bucket_id    = module.deployment_bucket.bucket_id
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
  ecs_cluster_name               = each.value.ecs_cluster_name
  ecs_service_name               = each.value.ecs_service_name
  ecs_deployment_timeout         = var.ecs_deployment_timeout
  image_detail_s3_bucket_id      = module.deployment_bucket.bucket_id
  image_detail_s3_object_key     = "ecs-${each.key}.json"
}

resource "aws_ssm_parameter" "ecs_source" {
  for_each = var.ecs_targets

  name = "ecs-${each.key}"
  type = "String"

  allowed_pattern = null # TODO
  data_type       = "text"
  description     = "Artifact Source for ECS '${each.key}'"
  insecure_value  = null
  key_id          = null
  overwrite       = true # REVIEW
  tags            = module.context.tags
  tier            = "Standard"
  value           = each.value.image_uri
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
