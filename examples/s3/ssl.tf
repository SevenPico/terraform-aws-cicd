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
##  ./examples/letsencrypt/ssl.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# SSL Certificate Context
# ------------------------------------------------------------------------------
module "ssl_certificate_context" {
  source  = "SevenPico/context/null"
  version = "2.0.0"
  context = module.context.self
}


# ------------------------------------------------------------------------------
# SSL Certificate
# ------------------------------------------------------------------------------
module "ssl_certificate" {
  #  source     = "registry.terraform.io/SevenPico/ssl-certificate/aws"
  #  version    = "8.0.11"
  source  = "git::https://github.com/SevenPico/terraform-aws-ssl-certificate.git?ref=hotfix/8.0.12"
  context = module.ssl_certificate_context.self

  replica_regions = []
  kms_key_id      = ""
  #  kms_key_enabled = true

  save_csr                            = false
  additional_dns_names                = []
  additional_secrets                  = {}
  create_mode                         = "LetsEncrypt"
  create_secret_update_sns            = true
  create_wildcard                     = true
  import_filepath_certificate         = null
  import_filepath_certificate_chain   = null
  import_filepath_csr                 = null
  import_filepath_private_key         = null
  import_secret_arn                   = null
  keyname_certificate                 = "CERTIFICATE"
  keyname_certificate_chain           = "CERTIFICATE_CHAIN"
  keyname_certificate_signing_request = "CERTIFICATE_SIGNING_REQUEST"
  keyname_private_key                 = "CERTIFICATE_PRIVATE_KEY"
  registration_email_address          = ""
  secret_read_principals              = {}
  secret_update_sns_pub_principals    = {}
  secret_update_sns_sub_principals    = {}
  zone_id                             = null
}