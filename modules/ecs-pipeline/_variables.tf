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
##  ./modules/ecs-pipeline/_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

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

variable "enable_ecs_standalone_task" {
  type    = bool
  default = false
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