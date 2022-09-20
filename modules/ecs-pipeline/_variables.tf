variable "ecs_cluster_name" {
  type = string
}

variable "ecs_service_name" {
  type = string
}

variable "ecs_deployment_timeout" {
  type    = number
  default = 15
}

variable "image_detail_s3_bucket_id" {
  type = string
}

variable "image_detail_s3_object_key" {
  type = string
}

variable "artifact_store_s3_bucket_id" {
  type    = string
  default = ""
}

variable "artifact_store_kms_key_arn" {
  type    = string
  default = ""
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}
