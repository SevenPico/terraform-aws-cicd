module "pipeline" {
  source  = "app.terraform.io/SevenPico/codepipeline/aws"
  version = "0.0.1"
  context = module.context.self

  artifact_store_s3_bucket_id    = var.artifact_store_s3_bucket_id
  artifact_store_kms_key_id      = var.artifact_store_kms_key_id
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days

  iam_policy_statements = {
    ecr = {
      effect = "Allow"
      actions = [
        "ecr:*", # FIXME
      ]
      resources = ["*"]
    }
  }

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
    {
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
