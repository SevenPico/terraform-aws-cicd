variable "root_domain" {}

variable "cors_allowed_origins" {
  type    = list(string)
  default = []
}

variable "cloudwatch_log_expiration_days" {
  type    = number
  default = 90
}

variable "s3_access_log_storage_bucket_id" {
  type = string
}

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 7
}

variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}

variable "overwrite_cicd_versions" {
  type    = bool
  default = false
}

variable "geo_restriction_locations" {
  type    = list(string)
  default = []
}

variable "enable_mfa_delete" {
  type    = bool
  default = false
}

variable "tls_protocol_version" {
  type    = string
  default = "TLSv1.2_2021"
}

variable "slack_notifications_enabled" {
  type    = bool
  default = false
}

variable "slack_token_secret_arn" {
  type    = string
  default = ""
}

variable "slack_token_secret_kms_key_arn" {
  type    = string
  default = ""
}

variable "slack_channel_ids" {
  type    = list(string)
  default = []
}

variable "default_root_object" {
  type    = string
  default = "index.html"
}


variable "error_response_page_path" {
  type    = string
  default = "/404.html"
}
