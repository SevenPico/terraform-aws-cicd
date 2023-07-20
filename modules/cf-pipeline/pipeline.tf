
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
        cf-source = {
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
    {
      name = "deploy"
      actions = {
        cf-deploy = {
          category = "Deploy"
          owner    = "AWS"
          provider = "CloudFormation"
          version  = "1"

          input_artifacts  = ["source"]
          output_artifacts = []

          configuration = {
            ActionMode    = "CREATE_UPDATE"
            Capabilities  = "CAPABILITY_NAMED_IAM,CAPABILITY_AUTO_EXPAND,CAPABILITY_IAM"
            ChangeSetName = "Cloudformation-Stack-Changes"
            RoleArn       = var.cloudformation_role_arn
            StackName     = var.cloudformation_stack_name
            TemplatePath  = "${var.source_s3_bucket_id}::${var.source_s3_object_key}"
          }
        }
      }
    },
  ]
}
