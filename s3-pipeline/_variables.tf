variable "type" {
  type        = string
  description = "Deployment target type"
  validation {
    condition     = contains(["s3-website", "ecs-service", "ecs-task", "lambda", "apigateway", "appsync"], var.type)
    error_message = "Unsupported type: ${var.type}"
  }
}

variable "s3_access_log_storage_bucket_id" {
  type    = string
  default = ""
}

variable "pre_deploy_environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
  }))

  default     = []
  description = "A list of maps, that contain the keys 'name', 'value', and 'type' to be used as additional environment variables for the build. Valid types are 'PLAINTEXT', 'PARAMETER_STORE', or 'SECRETS_MANAGER'"
}
