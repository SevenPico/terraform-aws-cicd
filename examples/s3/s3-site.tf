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
##  ./examples/complete/s3-site.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------
module "site" {
#  source  = "registry.terraform.io/SevenPico/s3-website/aws"
#  version = "2.0.1"
  source = "./module/cdn/"
  context = module.context.self
  depends_on = [
    aws_route53_zone.public
  ]

  acm_certificate_arn                     = module.ssl_certificate.acm_certificate_arn
  cors_allowed_origins                    = var.cors_allowed_origins
  geo_restriction_locations               = var.geo_restriction_locations
  parent_zone_id                          = aws_route53_zone.public[0].zone_id
#  tls_protocol_version                    = var.tls_protocol_version

#  additional_aliases                = []
  cloudfront_access_logging_enabled = true
  deployment_principal_arns         = {}
  dns_alias_enabled                 = true
  geo_restriction_type              = "blacklist"
  s3_object_ownership               = "BucketOwnerEnforced"
#  waf_enabled                       = false
  default_root_object               = var.default_root_object
  custom_error_response = [{
    error_caching_min_ttl = 10,
    error_code            = 404,
    response_code         = 404,
    response_page_path    = var.error_response_page_path
  }]
}


# ------------------------------------------------------------------------------
# Public Zone
# ------------------------------------------------------------------------------
data "aws_route53_zone" "root" {
  count = module.context.enabled ? 1 : 0
  name  = var.root_domain

}

resource "aws_route53_zone" "public" {
  #checkov:skip=CKV2_AWS_38:skip Domain Name System Security Extensions (DNSSEC) signing for Route 53 hosted zones
  #checkov:skip=CKV2_AWS_39:skip (DNS) query logging for Route 53 hosted zones
  count = module.context.enabled ? 1 : 0
  name  = module.context.domain_name
  tags  = module.context.tags
}

resource "aws_route53_record" "ns" {
  count   = module.context.enabled ? 1 : 0
  name    = module.context.id
  type    = "NS"
  zone_id = join("", data.aws_route53_zone.root[*].id)
  records = length(aws_route53_zone.public) > 0 ? aws_route53_zone.public[0].name_servers : []
  ttl     = 300
}
