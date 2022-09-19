variable "ecs_targets" {
  type = map(object({
    image_uri        = string
    ecs_cluster_name = string
    ecs_service_name = string
  }))
  default = {}
}

variable "s3_targets" {
  type = map(object({
    source_s3_bucket_id  = string
    source_s3_object_key = string
    target_s3_bucket_id  = string
    pre_deploy = object({
      buildspec   = string
      permissions = list(string)
      env_vars = list(object({
        name  = string
        value = string
        type  = string
        }
      ))
    })
  }))
  default = {}
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}

variable "ecs_deployment_timeout" {
  type    = string
  default = 15
}

variable "artifact_sns_topic_arn" {
  type    = string
  default = ""
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
  type    = string
  default = ""
}

variable "slack_token_secret_kms_key_arn" {
  type    = string
  default = ""
}

variable "create_kms_key" {
  type    = bool
  default = false
}

variable "kms_key_deletion_window_in_days" {
  type    = number
  default = 30
}

variable "kms_key_enable_key_rotation" {
  type    = bool
  default = true
}
