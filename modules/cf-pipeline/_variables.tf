variable "source_s3_bucket_id" {
  type = string
}

variable "source_s3_object_key" {
  type = string
}

variable "artifact_store_s3_bucket_id" {
  type = string
}

variable "artifact_store_kms_key_arn" {
  type = string
}

variable "pre_deploy_environment_variables" {
  type = list(object({
    name  = string
    value = string
    type  = string
    }
  ))

  default = [
    {
      name  = "NO_ADDITIONAL_BUILD_VARS"
      value = "TRUE"
      type  = "PLAINTEXT"
    }
  ]
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}

variable "cf_stack_name" {
  type    = string
  default = ""
}