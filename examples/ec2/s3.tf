# ------------------------------------------------------------------------------
# Source Bucket
# ------------------------------------------------------------------------------
module "source_bucket" {
  source     = "SevenPicoForks/s3-bucket/aws"
  version    = "4.0.4"
  context    = module.context.self
  attributes = ["source"]

  acl                           = "private"
  allow_encrypted_uploads_only  = var.allow_encrypted_uploads_only
  allow_ssl_requests_only       = var.allow_ssl_requests_only
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  enable_mfa_delete             = var.enable_mfa_delete
  force_destroy                 = true # no unique data stored here
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = []
  logging = var.access_log_bucket_name != null && var.access_log_bucket_name != "" ? {
    bucket_name = var.access_log_bucket_name
    prefix      = var.access_log_bucket_prefix_override == null ? "${local.account_id}/${module.context.id}/" : (var.access_log_bucket_prefix_override != "" ? "${var.access_log_bucket_prefix_override}/" : "")
  } : null
  object_lock_configuration     = null
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  restrict_public_buckets       = true
  s3_object_ownership           = var.s3_object_ownership
  s3_replica_bucket_arn         = ""
  s3_replication_enabled        = false
  s3_replication_rules          = null
  s3_replication_source_roles   = []
  source_policy_documents       = var.s3_source_policy_documents
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