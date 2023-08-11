module "pipeline" {
  source  = "../codepipeline"
  context = module.context.self

  artifact_store_s3_bucket_id    = var.artifact_store_s3_bucket_id
  artifact_store_kms_key_arn     = var.artifact_store_kms_key_arn
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
          s3-source = {
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
            output_artifacts = ["pre-deploy"]

            configuration = {
              ProjectName = module.pre_deploy_codebuild.project_name
            }
          }
        }
      } : null,
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
              ActionMode         = var.cloudformation_action_mode
              Capabilities       = var.cloudformation_capabilities
              ChangeSetName      = "Cloudformation-Stack-Changes"
              ParameterOverrides = var.cloudformation_parameter_overrides
              RoleArn            = var.cloudformation_role_arn
              StackName          = var.cloudformation_stack_name
              TemplatePath       = "source::${var.cloudformation_template_name}"
            }
          }
        }
      },
  ] : stage if stage != null]
}
