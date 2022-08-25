
variable "force_destroy" {
  type    = bool
  default = false
}

variable "lifecycle_configuration_rules" {
  type    = list(any)
  default = []
}

variable "read_principals" {
  type = list(string)
}

# variable "write_principals" {
# }

# variable "s3_access_log_storage_bucket_id" {
#   type    = string
#   default = ""
# }


# ------------------------------------------------------------------------------
# Artifacts S3 Bucket
# ------------------------------------------------------------------------------
module "artifacts_bucket" {
  source  = "app.terraform.io/SevenPico/s3-bucket/aws"
  version = "2.0.3"
  context = module.context.self

  acl                           = "private"
  allow_encrypted_uploads_only  = false
  allow_ssl_requests_only       = false
  allowed_bucket_actions        = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  force_destroy                 = var.force_destroy
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = var.lifecycle_configuration_rules
  lifecycle_rule_ids            = []
  lifecycle_rules               = null
  logging                       = null
  object_lock_configuration     = null
  policy                        = ""
  privileged_principal_actions  = ["s3:Get*", "s3:List*"]
  privileged_principal_arns     = [for p in var.read_principals : { "${p}" : [""] }]
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

# module "artifacts_bucket_policy" {
#   source     = "cloudposse/iam-policy/aws"
#   version    = "0.4.0"
#   context    = module.context.self
#   attributes = ["policy"]

#   description                   = null
#   iam_override_policy_documents = null
#   iam_policy_enabled            = false
#   iam_policy_id                 = null
#   iam_source_json_url           = null
#   iam_source_policy_documents   = null
#   iam_policy_statements = merge({
#     read = {
#       effect = "Allow"
#       actions = [
#       ]
#       resources  = ["*"]
#       principals = []
#     }
#   }, var.iam_policy_statements)
# }
