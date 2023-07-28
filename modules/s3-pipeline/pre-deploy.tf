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
##  ./modules/s3-pipeline/pre-deploy.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

# environment_variable {
#   name  = "AWS_REGION"
#   value = join("", data.aws_region.current[*].name)
# }
# environment_variable {
#   name  = "S3_TARGET_BUCKET"
#   value = "s3://${module.site.s3_bucket}"
# }

# environment_variable {
#   name  = "AWS_SECRETS_REGION"
#   value = join("", data.aws_region.current[*].name)
# }
# environment_variable {
#   name  = "S3_SECRETS_BUCKET"
#   value = "s3://${var.config_bucket_name}"
# }


# -----------------------------------------------------------------------------
# Codebuild Context
# -----------------------------------------------------------------------------
# module "pre_deploy_context" {
#   source     = "SevenPico/context/null"
#   version    = "2.0.0"
#   context    = module.context.self
# }


# -----------------------------------------------------------------------------
# Codebuild Project
# -----------------------------------------------------------------------------
module "pre_deploy_codebuild" {
  source     = "registry.terraform.io/SevenPico/codebuild/aws"
  version    = "2.0.2"
  context    = module.context.self
  enabled    = module.context.enabled && var.pre_deploy_enabled
  attributes = ["pre-deploy"]

  access_log_bucket_name                = ""
  artifact_location                     = ""
  artifact_type                         = "CODEPIPELINE"
  aws_account_id                        = ""
  aws_region                            = ""
  badge_enabled                         = false
  build_compute_type                    = "BUILD_GENERAL1_SMALL"
  build_image                           = var.build_image
  build_image_pull_credentials_type     = "CODEBUILD"
  build_timeout                         = 10
  build_type                            = "LINUX_CONTAINER"
  buildspec                             = var.pre_deploy_buildspec
  cache_bucket_suffix_enabled           = true
  cache_expiration_days                 = 7
  cache_type                            = "NO_CACHE"
  codebuild_policy_documents            = var.pre_deploy_policy_docs
  concurrent_build_limit                = null
  description                           = "Allows for changes to artifact files before deployment to the target bucket"
  encryption_enabled                    = false
  encryption_key                        = null
  environment_variables                 = var.pre_deploy_environment_variables
  fetch_git_submodules                  = false
  file_system_locations                 = {}
  git_clone_depth                       = null
  github_token                          = ""
  github_token_type                     = "PARAMETER_STORE"
  iam_permissions_boundary              = null
  iam_policy_path                       = "/service-role/"
  iam_role_path                         = null
  image_repo_name                       = "UNSET"
  image_tag                             = "latest"
  local_cache_modes                     = []
  logs_config                           = {}
  private_repository                    = false
  privileged_mode                       = false
  report_build_status                   = false
  s3_cache_bucket_name                  = null
  secondary_artifact_encryption_enabled = false
  secondary_artifact_identifier         = null
  secondary_artifact_location           = null
  secondary_sources                     = []
  source_credential_auth_type           = "PERSONAL_ACCESS_TOKEN"
  source_credential_server_type         = "GITHUB"
  source_credential_token               = ""
  source_credential_user_name           = ""
  source_location                       = ""
  source_type                           = "CODEPIPELINE"
  source_version                        = ""
  versioning_enabled                    = true
  vpc_config                            = {}
}


# -----------------------------------------------------------------------------
# Codebuild Log Group
# -----------------------------------------------------------------------------
# resource "aws_cloudwatch_log_group" "codebuild" {
#   count             = module.pre_deploy_context.enabled ? 1 : 0
#   name              = "/aws/codebuild/${module.pre_deploy_context.id}"
#   retention_in_days = var.cloudwatch_log_expiration_days
#   tags              = module.pre_deploy_context.tags
# }
