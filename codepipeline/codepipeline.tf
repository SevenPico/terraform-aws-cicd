locals {
  artifact_store_s3_bucket_id = coalesce(var.artifact_store_s3_bucket_id, module.artifact_store.bucket_id)
  artifact_store_kms_key_id   = var.artifact_store_kms_key_id
}


# ------------------------------------------------------------------------------
# Pipeline
# ------------------------------------------------------------------------------
resource "aws_codepipeline" "this" {
  count    = module.context.enabled ? 1 : 0
  name     = module.context.id
  role_arn = module.codepipeline_iam_role.arn

  artifact_store {
    location = local.artifact_store_s3_bucket_id
    type     = "S3"

    dynamic "encryption_key" {
      for_each = toset(var.artifact_store_kms_key_id == "" ? [] : [1])
      content {
        id   = local.artifact_store_kms_key_id
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
# Default Artifact Store
# ------------------------------------------------------------------------------
module "artifact_store" {
  source     = "app.terraform.io/SevenPico/s3-bucket/aws"
  version    = "2.0.3.2"
  context    = module.context.self
  enabled    = var.create_artifact_store_s3_bucket
  attributes = ["artifact-store"]

  acl                           = "private"
  allow_encrypted_uploads_only  = false
  allow_ssl_requests_only       = false
  allowed_bucket_actions        = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  force_destroy                 = false
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = []
  lifecycle_rule_ids            = []
  lifecycle_rules               = null
  logging                       = {}
  object_lock_configuration     = null
  policy                        = ""
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  replication_rules             = null
  restrict_public_buckets       = true
  s3_object_ownership           = "ObjectWriter"
  s3_replica_bucket_arn         = ""
  s3_replication_enabled        = false
  s3_replication_rules          = null
  s3_replication_source_roles   = []
  source_policy_documents       = []
  sse_algorithm                 = "AES256"
  transfer_acceleration_enabled = false
  user_enabled                  = false
  versioning_enabled            = true
  website_inputs                = null
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
    # FIXME - use a sane default and merge with optional input
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
    }
  }, var.iam_policy_statements)
}

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


# ------------------------------------------------------------------------------
# Cloudwatch Group
# ------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "pipeline" {
  count             = module.context.enabled ? 1 : 0
  name              = "/aws/codebuild/${module.context.id}"
  retention_in_days = var.cloudwatch_log_expiration_days
  tags              = module.context.tags
}

