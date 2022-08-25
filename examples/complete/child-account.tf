// service a
// service b

// site a
// site b

// lambda

// api
/*
module "ecs_service_cicd" {
  source  = "../"
  context = module.context.self
  name    = "cicd"

  ecs_cluster_name = aws_ecs_cluster.this.name
  ecs_service_name = module.service.service_name

  image_detail_s3_bucket_id  = "" #FIXME
  image_detail_s3_object_key = "" #FIXME

  artifact_store_kms_key_id       = ""
  artifact_store_s3_bucket_id     = ""
  cloudwatch_log_expiration_days  = 90
  create_artifact_store_s3_bucket = true
  ecs_deployment_timeout          = 15
}

module "artifacts_bucket" {
  source = "../../artifacts-bucket"
  #version = "FIXME"
  context = module.context.self
  name    = "artifacts"

  read_principals = [module.ecs_service_cicd.role_arn]
  rorce_destroy   = true
}
module "cicd" {
  artifact_monitor_sns_topic_arns = [module.artifact_monitor.sns_topic_arn]

  targets = {
    content-service = {
      type    = "ecs"
      source_path =
      key_format = "$source_path-$version"

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
*/
