# ------------------------------------------------------------------------------
# CI/CD
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "cloudformation_assume_role_policy" {
  count = module.context.enabled ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["cloudformation.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudformation_assume_role" {
  count              = module.context.enabled ? 1 : 0
  name               = "${module.context.id}-service-role"
  description        = "Prisma Cloud Integration IAM Role for an Organization Owner"
  assume_role_policy = data.aws_iam_policy_document.cloudformation_assume_role_policy[0].json
  tags               = module.context.tags
}

module "cicd" {
  source     = "../../"
  context    = module.context.self
  enabled    = module.context.enabled
  attributes = ["cicd"]

  access_log_bucket_name            = null
  access_log_bucket_prefix_override = null
  allow_ssl_requests_only           = true
  artifact_sns_topic_arn            = module.build_artifacts_bucket.bucket_arn
  cloudwatch_log_expiration_days    = 30
  cloudformation_targets = {
    cloudformation = {
      action_mode          = "CREATE_UPDATE"
      capabilities         = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
      parameter_overrides  = '{}'
      role_arn             = try(aws_iam_role.cloudformation_assume_role[0].arn, "")
      template_name        = "cloudformation-template.json"
      stack_name           = module.cloudformation_stack.name
      source_s3_bucket_id  = module.build_artifacts_bucket.bucket_arn
      source_s3_object_key = aws_s3_object.template_zip[0].key
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