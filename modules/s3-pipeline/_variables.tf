variable "target_s3_bucket_id" {
  type = string
}

variable "source_s3_bucket_id" {
  type = string
}

variable "source_s3_object_key" {
  type = string
}

variable "artifact_store_s3_bucket_id" {
  type = string
}

variable "artifact_store_kms_key_id" {
  type = string
}

variable "pre_deploy_enabled" {
  type    = bool
  default = false
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}
