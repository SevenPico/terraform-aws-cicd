# ------------------------------------------------------------------------------
# Pipeline
# ------------------------------------------------------------------------------
resource "aws_codepipeline" "this" {
  count    = module.context.enabled ? 1 : 0
  name     = module.context.id
  role_arn = module.codepipeline_iam_role.arn

  artifact_store {
    location = var.artifact_store_s3_bucket_id
    type     = "S3"

    dynamic "encryption_key" {
      for_each = toset(var.artifact_store_kms_key_arn == "" ? [] : [1])
      content {
        id   = var.artifact_store_kms_key_arn
        type = "KMS"
      }
    }
  }

  dynamic "stage" {
    for_each = toset(range(length(var.stages)))

    content {
      name = var.stages[stage.key].name

      dynamic "action" {
        for_each = var.stages[stage.key].actions
        content {
          name     = action.key
          category = action.value.category
          owner    = action.value.owner
          provider = action.value.provider
          version  = action.value.version

          configuration    = try(action.value.configuration, null)
          input_artifacts  = try(action.value.input_artifacts, null)
          output_artifacts = try(action.value.output_artifacts, null)
          role_arn         = try(action.value.role_arn, null)
          run_order        = try(action.value.run_order, null)
          region           = try(action.value.region, null)
          namespace        = try(action.value.namespace, action.key)
        }
      }
    }
  }
}


# ------------------------------------------------------------------------------
# IAM Role
# ------------------------------------------------------------------------------
module "codepipeline_iam_role" {
  source     = "cloudposse/iam-role/aws"
  version    = "0.16.2"
  context    = module.context.self
  attributes = ["role"]

  assume_role_actions      = ["sts:AssumeRole", "sts:TagSession"]
  assume_role_conditions   = []
  instance_profile_enabled = false
  managed_policy_arns      = []
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = ""
  policy_document_count    = 1
  policy_documents         = [module.codepipeline_iam_policy.json]
  principals = {
    Service = ["codepipeline.amazonaws.com"]
  }
  role_description = "CodePipeline IAM Role for ${module.context.id}"
  tags_enabled     = true
  use_fullname     = true
}

module "codepipeline_iam_policy" {
  source     = "cloudposse/iam-policy/aws"
  version    = "0.4.0"
  context    = module.context.self
  attributes = ["policy"]

  description                   = null
  iam_override_policy_documents = null
  iam_policy_enabled            = false
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null
  iam_policy_statements = merge({
    # FIXME - use a sane defaults and merge with optional input
    default = {
      effect = "Allow"
      actions = [
        "ec2:*",
        "elasticloadbalancing:*",
        "autoscaling:*",
        "cloudwatch:*",
        "s3:*",
        "sns:*",
        "cloudformation:*",
        "rds:*",
        "sqs:*",
        "ecs:*",
        "iam:PassRole"
      ]
      resources  = ["*"]
      conditions = []
    },
    # FIXME
    # kms = {
    #   effect    = "Allow"
    #   actions   = ["kms:Encrypt", "kms:Decrypt", "kms:DescribeKey"]
    #   resources = [var.artifact_store_kms_key_arn]
    # }
  }, var.iam_policy_statements)
}


# ------------------------------------------------------------------------------
# Cloudwatch Group
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "pipeline" {
  count             = module.context.enabled ? 1 : 0
  name              = "/aws/codebuild/${module.context.id}"
  retention_in_days = var.cloudwatch_log_expiration_days
  tags              = module.context.tags
}
