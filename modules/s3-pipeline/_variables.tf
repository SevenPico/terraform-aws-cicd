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
##  ./modules/s3-pipeline/_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

variable "target_s3_bucket_id" {
  type = string
}

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

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
}
