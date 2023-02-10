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
##  ./examples/complete/child-account.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

module "cicd" {
  source  = "../../"
  context = module.context.self
  name    = "cicd"

  artifact_bucket_id     = module.artifact_bucket.bucket_id
  artifact_sns_topic_arn = module.artifact_monitor.sns_topic_arn

  ecs_targets = {
    foo = {
      image_uri        = "${module.ecr.repository_url_map["foo"]}:latest"
      ecs_cluster_name = aws_ecs_cluster.this.name
      ecs_service_name = module.foo_service.service_name
    }
    bar = {
      image_uri        = "${module.ecr.repository_url_map["bar"]}:latest"
      ecs_cluster_name = aws_ecs_cluster.this.name
      ecs_service_name = module.bar_service.service_name
    }
  }

  s3_targets = {
    foo = {
      source_s3_bucket_id  = module.artifact_bucket.bucket_id
      source_s3_object_key = "sites/foo/foo-latest.zip"
      target_s3_bucket_id  = module.site_bucket["foo"].bucket_id
      pre_deploy = {
        buildspec   = "deployspec.yml"
        permissions = []
        env_vars    = []
      }
    }
    bar = {
      source_s3_bucket_id  = module.artifact_bucket.bucket_id
      source_s3_object_key = "sites/bar/bar-latest.zip"
      target_s3_bucket_id  = module.site_bucket["bar"].bucket_id
      pre_deploy           = null
    }
  }
}
