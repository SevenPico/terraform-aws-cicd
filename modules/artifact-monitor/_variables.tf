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
##  ./modules/artifact-monitor/_variables.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

variable "ecr_repository_url_map" {
  type    = map(string)
  default = {}
}

variable "s3_bucket_ids" {
  type    = list(string)
  default = []
}

variable "sns_pub_principals" {
  type = map(object({
    type        = string
    identifiers = list(string)
    condition   = any
  }))
  default     = {}
  description = <<EOF
The following example input Allows for the specification of Principals as well as Principals with Conditions.
If no Conditions are needed, the Condition block can be set to null, but that needs to be consistent for each map item
{
    RootAccess = {
      type = "AWS"
      identifiers = [var.principal_account_id]
      condition = {
        test     = null
        values   = []
        variable =
      }
    },
    PubConditional = {
      type = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = [var.organization_ou_id]
        variable = "aws:PrincipalOrgPaths"
      }
    }
}
EOF
}

variable "sns_sub_principals" {
  type = map(object({
    type        = string
    identifiers = list(string)
    condition   = any
  }))
  default     = {}
  description = <<EOF
The following example input Allows for the specification of Principals as well as Principals with Conditions.
If no Conditions are needed, the Condition block can be set to null, but that needs to be consistent for each map item
{
    RootAccess = {
      type = "AWS"
      identifiers = [var.principal_account_id]
      condition = {
        test     = null
        values   = []
        variable =
      }
    },
    PubConditional = {
      type = "AWS"
      identifiers = ["*"]
      condition = {
        test     = "ForAnyValue:StringLike"
        values   = [var.organization_ou_id]
        variable = "aws:PrincipalOrgPaths"
      }
    }
}
EOF
}

variable "cloudwatch_log_expiration_days" {
  type    = string
  default = 90
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
  type = string
  default = ""
}
variable "slack_token_secret_kms_key_arn" {
  type = string
  default = ""
}
