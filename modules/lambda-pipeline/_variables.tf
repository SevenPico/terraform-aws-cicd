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

variable "build_image" {
  type        = string
  default     = "aws/codebuild/standard:2.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "buildspec" {
  type    = string
  default = "deployspec.yml"
}

variable "build_policy_docs" {
  type    = list(string)
  default = []
}

variable "build_environment_variables" {
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
