# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "s3_website_deploy_context" {
  source  = "app.terraform.io/SevenPico/context/null"
  version = "0.0.1"
  context = module.context.self
  enabled = module.context.self && var.type == "s3-website"
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
resource "aws_codepipeline" "s3_website_deploy" {
  count = module.s3_website_deploy_context.enabled ? 1 : 0

  name = module.s3_website_deploy_context.id

  role_arn = var.codepipeline_role_arn
  tags     = module.this.context.tags

  artifact_store {
    location = var.deployment_bucket_name
    type     = "S3"
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      input_artifacts  = []
      output_artifacts = ["${module.this.id}-artifacts"]
      configuration = {
        S3Bucket             = var.deployment_bucket_name
        S3ObjectKey          = "${module.this.id}.zip"
        PollForSourceChanges = true
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name             = "S3-Pre-Deploy"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["${module.this.id}-artifacts"]
      output_artifacts = []
      version          = "1"
      configuration = {
        ProjectName = local.codebuild_name
      }
    }

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "S3"
      input_artifacts  = ["${module.this.id}-artifacts"]
      output_artifacts = []
      version          = "1"
      configuration = {
        BucketName = module.site.s3_bucket
        Extract    = "true"
      }
    }
  }
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "s3_website_deploy_role" {
  source     = "cloudposse/iam-role/aws"
  version    = "0.16.2"
  context    = module.pre_deploy_context.self
  attributes = ["role"]

  assume_role_actions    = ["sts:AssumeRole", "sts:TagSession"]
  assume_role_conditions = []
  principals = {
    # FIXME
    Service = ["codebuild.amazonaws.com", "codepipeline.amazonaws.com", "ec2.amazonaws.com"]
  }
  instance_profile_enabled = false
  managed_policy_arns      = []
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = ""
  policy_document_count    = 1
  policy_documents         = []
  description              = "FIXME"
  tags_enabled             = true
  use_fullname             = true
}


data "aws_iam_policy_document" "default_pre_deploy_role_policy" {
  count   = module.pre_deploy_context.enabled ? 1 : 0
  version = "2012-10-17"
  # FIXME
  # statement {
  #   sid    = "CloudWatchLogsPolicy"
  #   effect = "Allow"
  #   actions = [
  #     "logs:CreateLogGroup",
  #     "logs:CreateLogStream",
  #     "logs:PutLogEvents"
  #   ]
  #   resources = ["*"]
  # }
  # statement {
  #   actions = [
  #     "s3:List*",
  #     "s3:Get*"
  #   ]
  #   effect = "Allow"
  #   resources = [
  #     module.static_site_config_s3_bucket.bucket_arn,
  #     "${module.static_site_config_s3_bucket.bucket_arn}/*"
  #   ]
  # }
  # statement {
  #   actions = [
  #     "s3:Get*",
  #     "s3:List*",
  #     "s3:Put*"
  #   ]
  #   effect = "Allow"
  #   resources = [
  #     module.deployment_queue_s3_bucket.bucket_arn,
  #     "${module.deployment_queue_s3_bucket.bucket_arn}/*"
  #   ]
  # }
  # statement {
  #   actions = ["iam:PassRole"]
  #   condition {
  #     test = "StringEqualsIfExists"
  #     values = [
  #       "ec2.amazonaws.com",
  #     ]
  #     variable = "iam:PassedToService"
  #   }
  #   effect    = "Allow"
  #   resources = ["*"]
  # }
  # statement {
  #   actions = [
  #     "codedeploy:CreateDeployment",
  #     "codedeploy:GetApplication",
  #     "codedeploy:GetApplicationRevision",
  #     "codedeploy:GetDeployment",
  #     "codedeploy:GetDeploymentConfig",
  #     "codedeploy:RegisterApplicationRevision"
  #   ]
  #   effect    = "Allow"
  #   resources = ["*"]
  # }
  # statement {
  #   actions = [
  #     "codebuild:BatchGetBuilds",
  #     "codebuild:StartBuild"
  #   ]
  #   effect    = "Allow"
  #   resources = ["*"]
  # }
}

