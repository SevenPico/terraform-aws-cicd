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

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}

variable "cloudformation_stack_name" {
  type    = string
  default = ""
}

variable "pre_deploy_enabled" {
  type    = bool
  default = false
}

variable "pre_deploy_buildspec" {
  type    = string
  default = "deployspec.yml"
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
variable "pre_deploy_policy_docs" {
  type    = list(string)
  default = []
}

variable "build_image" {
  type        = string
  default     = "aws/codebuild/standard:2.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "cloudformation_role_arn" {
  type        = string
  default     = ""
  description = "This property is required for the following action modes `CREATE_UPDATE`,`REPLACE_ON_FAILURE`, `DELETE_ONLY`, `CHANGE_SET_REPLACE`"
}

variable "cloudformation_template_name" {
  type = string
}

variable "cloudformation_parameter_overrides" {
  type    = string
  default = "{}"
  description = <<EOF
Allows you to input custom values when you create or update a stack.
"{\"InstanceType\" : \"t2.small\",\"KeyName\": \"my-keypair\"}"
EOF
}

variable "cloudformation_action_mode" {
  type    = string
  default = "CREATE_UPDATE"
}

variable "cloudformation_capabilities" {
  type    = string
  default = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
}

