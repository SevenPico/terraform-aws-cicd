variable "stages" {
  type = any
}

variable "create_artifact_store_s3_bucket" {
  type    = bool
  default = false
}

variable "artifact_store_s3_bucket_id" {
  type    = string
  default = ""
}

variable "artifact_store_kms_key_id" {
  type    = string
  default = ""
  description = "If undefined, then default key for S3 is used."
}

variable "cloudwatch_log_expiration_days" {
  type    = number
  default = 90
}

variable "iam_policy_statements" {
  type    = map(any)
  default = {}
}
