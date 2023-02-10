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
