variable "ecr_repository_url_map" {
  type    = map(string)
  default = {}
}

variable "s3_bucket_ids" {
  type    = list(string)
  default = []
}

variable "sns_pub_principals" {
  type    = map(list(string))
  default = {}
}

variable "sns_sub_principals" {
  type    = map(list(string))
  default = {}
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}

variable "slack_notifications_enabled" {
  type    = bool
  default = false
}

variable "slack_channel_ids" {
  type    = list(string)
  default = []
}

variable "slack_token_secret_arn" {
  type = string
  default = ""
}
variable "slack_token_secret_kms_key_arn" {
  type = string
  default = ""
}
