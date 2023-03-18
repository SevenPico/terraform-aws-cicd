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
##  ./_outputs.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

output "kms_key_arn" {
  value       = module.kms_key.key_arn
  description = "Key ARN"
}

output "kms_key_id" {
  value       = module.kms_key.key_id
  description = "Key ID"
}

output "kms_key_alias_arn" {
  value       = module.kms_key.alias_arn
  description = "Alias ARN"
}

output "kms_key_alias_name" {
  value       = module.kms_key.alias_name
  description = "Alias name"
}

output "ecs_pipelines_names_map" {
  value = { for k,v in module.ecs_pipeline: k => v.id }
}

output "s3_pipelines_names_map" {
  value = { for k,v in module.s3_pipeline: k => v.id }
}

output "ecs_target_version_ssm_parameter_names_map" {
  value = local.ecs_target_version_ssm_parameter_names_map
}
output "s3_target_version_ssm_parameter_names_map" {
  value = local.s3_target_version_ssm_parameter_names_map
}
