resource "aws_codepipeline" "this" {
  count    = module.context.enabled ? 1 : 0
  name     = module.context.id
  role_arn = module.codepipeline_iam_role.arn

  dynamic "artifact_store" {
    for_each = var.artifact_stores
    content {
      location = artifact_store.value.location
      type     = try(artifact_store.value.type, "S3")
      region   = try(artifact_store.value.region, null)

      dynamic "encryption_key" {
        for_each = toset(can(artifact_store.value.kms_key_arn) ? [1] : [])
        content {
          id   = encryption_key.value.kms_key_arn
          type = "KMS"
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.stages
    content {
      name = stage.key
      dynamic "action" {
        for_each = stage.value
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
  policy_documents         = []
  principals = {
    Service = ["codepipeline.amazonaws.com"]
  }
  role_description = "CodePipeline IAM Role for ${module.context.id}"
  tags_enabled     = true
  use_fullname     = true
}

# FIXME
# data "aws_iam_policy_document" "default" {
#   statement {
#     sid = ""

#     actions = [
#       "ec2:*",
#       "elasticloadbalancing:*",
#       "autoscaling:*",
#       "cloudwatch:*",
#       "s3:*",
#       "sns:*",
#       "cloudformation:*",
#       "rds:*",
#       "sqs:*",
#       "ecs:*",
#       "iam:PassRole"
#     ]

#     resources = ["*"]
#     effect    = "Allow"
#   }
# }

# data "aws_iam_policy_document" "s3" {
#   count = module.this.enabled ? 1 : 0

#   statement {
#     sid = ""

#     actions = [
#       "s3:GetObject",
#       "s3:GetObjectVersion",
#       "s3:GetBucketVersioning",
#       "s3:PutObject"
#     ]

#     resources = [
#       join("", aws_s3_bucket.default.*.arn),
#       "${join("", aws_s3_bucket.default.*.arn)}/*"
#     ]

#     effect = "Allow"
#   }
# }
