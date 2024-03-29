## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

variable "ecs_targets" {
  type = map(object({
    image_uri        = string
    ecs_cluster_name = string
    ecs_service_name = string
  }))
  default = {}
}

variable "ecs_standalone_task_targets" {
  type = map(object({
    image_uri = string
    build = object({
      buildspec   = string
      policy_docs = list(string)
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

variable "enable_ecs_standalone_task" {
  type    = bool
  default = false
}

variable "s3_targets" {
  type = map(object({
    source_s3_bucket_id    = string
    source_s3_object_key   = string
    target_s3_bucket_id    = string
    ssm_artifact_uri_value = string #This value will be a URI for the build artifacts .zip file, which will be saved in the ssm parameter store.
    pre_deploy = object({
      buildspec   = string
      policy_docs = list(string)
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

variable "cloudformation_targets" {
  type = map(object({
    action_mode          = string
    file_type            = string
    capabilities         = string
    parameter_overrides  = string
    role_arn             = string
    source_s3_bucket_id  = string
    source_s3_object_key = string
    stack_name           = string
    template_name        = string
    pre_deploy = object({
      buildspec   = string
      policy_docs = list(string)
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

variable "ec2_targets" {
  type = map(object({
    source_s3_bucket_id  = string
    source_s3_object_key = string
    file_type            = string
    build = object({
      buildspec   = string
      policy_docs = list(string)
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

variable "source_s3_bucket_id" {
  type    = string
  default = ""
}

variable "source_s3_object_key" {
  type    = string
  default = ""
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

variable "overwrite_ssm_parameters" {
  type    = bool
  default = false
}

variable "enable_mfa_delete" {
  type        = bool
  default     = false
  description = "Set this to true to enable MFA on bucket. You must also set `versioning_enabled` to `true`."
}

variable "s3_object_ownership" {
  type        = string
  default     = "BucketOwnerEnforced"
  description = "Specifies the S3 object ownership control. Valid values are `ObjectWriter`, `BucketOwnerPreferred`, and 'BucketOwnerEnforced'."
}

variable "access_log_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the S3 bucket where S3 access logs will be sent to"
}

variable "access_log_bucket_prefix_override" {
  type        = string
  default     = ""
  description = "Prefix to prepend to the current S3 bucket name, where S3 access logs will be sent to"
}

variable "allow_encrypted_uploads_only" {
  type    = bool
  default = false
}

variable "allow_ssl_requests_only" {
  type    = bool
  default = true
}

variable "s3_source_policy_documents" {
  type        = list(string)
  default     = []
  description = <<-EOT
    List of IAM policy documents that are merged together into the exported document.
    Statements defined in source_policy_documents must have unique SIDs.
    Statement having SIDs that match policy SIDs generated by this module will override them.
    EOT
}

variable "build_image" {
  type        = string
  default     = "aws/codebuild/standard:2.0"
  description = "Docker image for build environment, e.g. 'aws/codebuild/standard:2.0' or 'aws/codebuild/eb-nodejs-6.10.0-amazonlinux-64:4.0.0'. For more info: http://docs.aws.amazon.com/codebuild/latest/userguide/build-env-ref.html"
}

variable "cloudformation_stack_name" {
  type    = string
  default = ""
}