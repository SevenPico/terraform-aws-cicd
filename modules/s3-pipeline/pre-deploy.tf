
# # -----------------------------------------------------------------------------
# # Codebuild Log Group
# # -----------------------------------------------------------------------------
# resource "aws_cloudwatch_log_group" "codebuild" {
#   count             = module.context.enabled ? 1 : 0
#   name              = "/aws/codebuild/${aws_codebuild_project.this[0].name}"
#   retention_in_days = var.cloudwatch_log_expiration_days
#   tags              = module.context.tags
# }

# # -----------------------------------------------------------------------------
# # Codebuild Project
# # -----------------------------------------------------------------------------
# locals {
#   codebuild_name    = format("%s-deployment-worker", coalesce(module.context.id, "na"))
#   codepipeline_name = format("%s-pipeline", coalesce(module.context.id, "na"))
# }

# resource "aws_codebuild_project" "this" {
#   count          = module.context.enabled ? 1 : 0
#   name           = local.codebuild_name
#   description    = "Allows for changes to files upon deployment to the CDN"
#   build_timeout  = "5"
#   queued_timeout = "5"
#   service_role   = var.codepipeline_role_arn

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   cache {
#     type  = "LOCAL"
#     modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
#   }

#   logs_config {
#     cloudwatch_logs {
#       status = "ENABLED"
#     }
#   }

#   environment {
#     compute_type                = "BUILD_GENERAL1_SMALL"
#     image                       = "aws/codebuild/standard:2.0"
#     type                        = "LINUX_CONTAINER"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "AWS_REGION"
#       value = join("", data.aws_region.current[*].name)
#     }
#     environment_variable {
#       name  = "S3_TARGET_BUCKET"
#       value = "s3://${module.site.s3_bucket}"
#     }

#     environment_variable {
#       name  = "AWS_SECRETS_REGION"
#       value = join("", data.aws_region.current[*].name)
#     }
#     environment_variable {
#       name  = "S3_SECRETS_BUCKET"
#       value = "s3://${var.config_bucket_name}"
#     }
#   }

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "deployspec.yml"
#   }

#   tags = module.context.tags
# }
