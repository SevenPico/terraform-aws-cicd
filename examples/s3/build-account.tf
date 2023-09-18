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
##  ./examples/complete/build-account.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

module "artifact_bucket" {
  source     = "SevenPicoForks/s3-bucket/aws"
  version    = "4.0.1"
  context    = module.context.self
  attributes = ["artifacts"]
}

module "artifact_monitor" {
  source  = "../../modules/artifact-monitor"
  context = module.context.self

  ecr_repository_url_map = {}
  s3_bucket_ids          = [module.artifact_bucket.bucket_id]
}
