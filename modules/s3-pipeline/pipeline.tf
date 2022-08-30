module "pipeline" {
  source  = "app.terraform.io/SevenPico/codepipeline/aws"
  version = "0.0.1"
  context = module.context.self

  artifact_store_s3_bucket_id    = var.artifact_store_s3_bucket_id
  artifact_store_kms_key_id      = var.artifact_store_kms_key_id
  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
  iam_policy_statements = var.pre_deploy_enabled ? {
    codebuild = {
      effect    = "Allow"
      actions   = ["codebuild:*"]
      resources = [module.pre_deploy_codebuild.project_arn]
    }
  } : {}

  stages = [
    for stage in [
      {
        name = "source"
        actions = {
          s3-soruce = {
            category = "Source"
            owner    = "AWS"
            provider = "S3"
            version  = "1"

            input_artifacts  = []
            output_artifacts = ["source"]

            configuration = {
              S3Bucket    = var.source_s3_bucket_id
              S3ObjectKey = var.source_s3_object_key
            }
          }
        }
      },

      var.pre_deploy_enabled ? {
        name = "pre-deploy"
        actions = {
          codebuild = {
            category = "Build"
            owner    = "AWS"
            provider = "CodeBuild"
            version  = "1"

            input_artifacts  = ["source"]
            output_artifacts = []

            configuration = {
              ProjectName = module.pre_deploy_codebuild.project_name
            }
          }
        }
      } : null,

      {
        name = "deploy"
        actions = {
          s3-deploy = {
            category = "Deploy"
            owner    = "AWS"
            provider = "S3"
            version  = "1"

            input_artifacts  = ["source"]
            output_artifacts = []

            configuration = {
              BucketName = var.target_s3_bucket_id
              Extract    = true
            }
          }
        }
      },
  ] : stage if stage != null]
}
