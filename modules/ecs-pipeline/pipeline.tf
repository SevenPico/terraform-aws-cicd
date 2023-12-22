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
##  ./modules/ecs-pipeline/pipeline.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

module "pipeline" {
  source  = "../codepipeline"
  context = module.context.self

  artifact_store_s3_bucket_id    = var.artifact_store_s3_bucket_id
  artifact_store_kms_key_arn     = var.artifact_store_kms_key_arn
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
  iam_policy_statements          = {}

  stages = [
    {
      name = "source"
      actions = {
        s3 = {
          category = "Source"
          owner    = "AWS"
          provider = "S3"
          version  = "1"

          input_artifacts  = []
          output_artifacts = ["source"]

          configuration = {
            S3Bucket    = var.image_detail_s3_bucket_id
            S3ObjectKey = var.image_detail_s3_object_key
          }
        }
      }
    },
    var.enable_ecs_standalone_task ? {
      name = "deploy"
      actions = {
        codebuild = {
          category = "Build"
          owner    = "AWS"
          provider = "CodeBuild"
          version  = "1"

          input_artifacts  = ["source"]
          output_artifacts = []

          configuration = {
            ProjectName = module.codebuild.project_name
          }
        }
      }
    } : {
      name = "deploy"
      actions = {
        ecs = {
          category = "Deploy"
          owner    = "AWS"
          provider = "ECS"
          version  = "1"

          input_artifacts  = ["source"]
          output_artifacts = []

          configuration = {
            ClusterName       = var.ecs_cluster_name
            ServiceName       = var.ecs_service_name
            DeploymentTimeout = var.ecs_deployment_timeout
            FileName          = "imagedefinitions.json"
          }
        }
      }
    },
  ]
}
