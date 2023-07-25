# ------------------------------------------------------------------------------
# CI/CD Artifact Monitor
# ------------------------------------------------------------------------------
module "artifact_monitor" {
  source  = "../../modules/artifact-monitor"
  context = module.context.self
  name    = "monitor"

  cloudwatch_log_expiration_days = 30
  ecr_repository_url_map         = {}
  s3_bucket_ids                  = [module.build_artifacts_bucket.bucket_id]
  slack_notifications_enabled    = false
  sns_pub_principals             = {}
  sns_sub_principals             = {}
}



# ------------------------------------------------------------------------------
# CI/CD
# ------------------------------------------------------------------------------
module "cloudformation_role_arn" {
  source  = "SevenPicoForks/iam-role/aws"
  version = "2.0.0"
  context = module.context.self
  enabled = module.context.enabled

  assume_role_actions      = ["sts:AssumeRole"]
  assume_role_conditions   = []
  instance_profile_enabled = false
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
  max_session_duration  = 3600
  path                  = "/"
  permissions_boundary  = ""
  policy_description    = "VPN Server Permissions"
  policy_document_count = 0
  policy_documents      = []
  principals = {
    Service : [
      "cloudformation.amazonaws.com"
    ]
  }
  role_description = "IAM role with permissions to perform actions required by the Cloudformation"
  use_fullname     = true
}

module "cicd" {
  source     = "../../"
  context    = module.context.self
  attributes = ["cicd"]
  enabled    = module.context.enabled
  depends_on = [module.build_artifacts_bucket, aws_s3_object.template_zip]

  access_log_bucket_name            = null
  access_log_bucket_prefix_override = null
  allow_ssl_requests_only           = true
  artifact_sns_topic_arn            = module.artifact_monitor.sns_topic_arn
  cloudwatch_log_expiration_days    = 30
  cloudformation_targets = {
    cloudformation = {
      action_mode          = "CREATE_UPDATE"
      capabilities         = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
      parameter_overrides  = "{}"
      role_arn             = try(module.cloudformation_role_arn[0].arn, "")
      template_name        = "cloudformation-template.json"
      stack_name           = module.cloudformation_stack.name
      source_s3_bucket_id  = module.build_artifacts_bucket.bucket_arn
      source_s3_object_key = try(aws_s3_object.template_zip[0].key, "")
    }
  }
  create_kms_key              = true
  ecs_deployment_timeout      = 15 # min
  ecs_targets                 = {}
  overwrite_ssm_parameters    = false
  s3_object_ownership         = "BucketOwnerEnforced"
  s3_source_policy_documents  = []
  s3_targets                  = {}
  slack_notifications_enabled = false
}