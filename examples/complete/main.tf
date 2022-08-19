# ------------------------------------------------------------------------------
# In admin/build account
# ------------------------------------------------------------------------------
module "ecr" {
  source  = "registry.terraform.io/cloudposse/ecr/aws"
  version = "0.34.0"
  context = module.this.context
}

// For static sites, lambdas, etc
module "artifacts_bucket" {
  source     = "registry.terraform.io/cloudposse/s3-bucket/aws"
  version    = "2.0.3"
  context    = module.this.context
  attributes = ["artifacts"]
}

// S3 bucket, ECR w/ SNS topic for artifact events


// Setups monitors on each of the artifact sources, yields sns topic
// Notifies on new release of artifacts
// - event setup
// - lambda listener and re-broadcast in known format
// ecs
module "artifacts_monitor" {
  sources = {
    producer-service = {
      type = "ecr"
      uri  = "029425144583.dkr.ecr.us-east-1.amazonaws.com/content"
    }
    fulfillment-service = {
      type = "ecr"
      uri  = "029425144583.dkr.ecr.us-east-1.amazonaws.com/fulfillment"
    }
    sites = {
      type       = "s3"
      uri        = "s3://cmbg-artifacts/sites"
      key_format = "$${name}-$${version}.zip"
    }
    lambdas = {
      type       = "s3"
      uri        = "s3://cmbg-artifacts/lambdas"
      key_format = "$${name}-$${version}.zip"
    }
    api-gateway-schema = {
      type       = "s3"
      uri        = "s3://cmbg-artifacts/lambdas"
      key_format = "$${name}-$${version}.json"
    }
    amplify-schema = {
      type       = "s3"
      uri        = "s3://cmbg-artifacts/lambdas"
      key_format = "$${name}-$${version}.json"
    }
  }

  # allow child accounts to subscribe
  # output SNS topic arns
  # output artifact sources

}


# ------------------------------------------------------------------------------
# In child environment
# ------------------------------------------------------------------------------
# - deployment lambda (optional subscribe to monitor sns)
#   expects event in format
/*
[
  {
    id : ""
    source : ""
  }
]
*/
module "cicd" {
  artifact_monitor_sns_topic_arns = [module.artifact_monitor.sns_topic_arn]

  targets = {
    content-service = {
      type    = "ecs"
      arn     = module.content_service.arn
      version = "latest"
    }
    fulfillment-service = {
      type    = "ecs"
      version = "1.2.3"
    }
    order-site = {
      type    = "s3-website"
      source  = "s3://cmbg-artifacts/order-site"
      uri     = "s3://${module.order_site.s3_bucket}"
      version = "latest"
    }
    payment-site = {
      type       = "s3-website"
      source     = "s3://cmbg-artifacts/payment-site"
      version    = "1.2.3"
      key_format = "$${name}-$${version}.zip"
    }
    vpn-api-lambda = {
      type    = "lambda"
      source  = "s3://cmbg-artifacts/payment-site"
      version = "1.2.3"
    }
  }



  pre_deploy_environment_variables = [
    {
      name  = "S3_TARGET_BUCKET",
      value = var.s3_site_origin_bucket
      type  = "PLAINTEXT",
    },
    {
      name  = "AWS_REGION",
      value = data.aws_region.current[0].name,
      type  = "PLAINTEXT",
    },
    {
      name  = "AWS_SECRETS_REGION",
      value = data.aws_region.current[0].name,
      type  = "PLAINTEXT",
    },
    {
      name  = "S3_SECRETS_BUCKET"
      value = "s3://${var.config_bucket_name}"
      type  = "PLAINTEXT",
    },
  ]

}




/*
- May not need `auto_deploy` bool as versions should be immutable and mutable tags imply auto-deploy is desired

- Do we keep state of desired verison (in ddb table)
or does invoke of lambda (with desired version) set the current version (maybe not in ddb table)

TODO
- deployment lambda (deploy logic for each target type)
- desired version table (dynamodb) - default ddb item for each target with version provided
-



https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification
resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id

  topic {
    topic_arn     = aws_sns_topic.topic.arn
    events        = ["s3:ObjectCreated:*"]
    filter_suffix = ".log"
  }
}
*/
