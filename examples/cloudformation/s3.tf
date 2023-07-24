# ------------------------------------------------------------------------------
# Deployer Lambda Context
# ------------------------------------------------------------------------------
module "s3_bucket_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["build"]
  enabled    = module.context.enabled
}


# ------------------------------------------------------------------------------
# Artifact Bucket for use by Deployer Lambda and Pipelines
# ------------------------------------------------------------------------------
data "archive_file" "artifact" {
  depends_on  = [module.build_artifacts_bucket]
  count       = module.s3_bucket_context.enabled ? 1 : 0
  type        = "zip"
  source_file = "${path.module}/cloudformation-template.yaml"
  output_path = "${path.module}/cloudformation-template.zip"
}

module "build_artifacts_bucket" {
  source     = "SevenPicoForks/s3-bucket/aws"
  version    = "4.0.4"
  context    = module.s3_bucket_context.self
  attributes = ["artifacts"]

  allow_encrypted_uploads_only  = false
  allow_ssl_requests_only       = true
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  enable_mfa_delete             = false
  force_destroy                 = true # no unique data stored here
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = []
  logging                       = null
  object_lock_configuration     = null
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  restrict_public_buckets       = true
  s3_object_ownership           = "BucketOwnerEnforced"
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
  allowed_bucket_actions = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]
}


resource "aws_s3_object" "template_file" {
  count      = module.s3_bucket_context.enabled ? 1 : 0
  depends_on = [module.build_artifacts_bucket]

  bucket = module.build_artifacts_bucket.bucket_arn
  key    = "cloudformation/0.0.1/cloudformation-template.yaml"
  source = "${path.module}/cloudformation-template.yaml"
}

resource "aws_s3_object" "template_zip" {
  count      = module.s3_bucket_context.enabled ? 1 : 0
  depends_on = [module.build_artifacts_bucket]

  bucket = module.build_artifacts_bucket.bucket_arn
  key    = "cloudformation/0.0.1/cloudformation-template-0.0.1.zip"
  source = data.archive_file.artifact[0].id
}