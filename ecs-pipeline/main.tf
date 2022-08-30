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

# data "aws_iam_policy_document" "pipeline_assume_role_policy" {
#   count   = module.pipeline_context.enabled ? 1 : 0
#   version = "2012-10-17"
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#     principals {
#       identifiers = ["codepipeline.amazonaws.com"]
#       type        = "Service"
#     }
#   }
#   statement {
#     actions = ["sts:AssumeRole"]
#     effect  = "Allow"
#     principals {
#       identifiers = ["codebuild.amazonaws.com"]
#       type        = "Service"
#     }
#   }
# }

# # FIXME - likely doesn't need all these permissions
# data "aws_iam_policy_document" "pipeline_policy" {
#   count   = module.pipeline_context.enabled ? 1 : 0
#   version = "2012-10-17"
#   statement {
#     actions = [
#       "ecs:DescribeServices",
#       "ecs:DescribeTaskDefinition",
#       "ecs:DescribeTasks",
#       "ecs:ListTasks",
#       "ecs:RegisterTaskDefinition",
#       "ecs:RunTask",
#       "ecs:UpdateService"
#     ]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#   statement {
#     actions   = ["iam:PassRole"]
#     effect    = "Allow"
#     resources = ["*"]
#     condition {
#       test = "StringLike"
#       values = [
#         "ecs-tasks.amazonaws.com",
#         "ec2.amazonaws.com"
#       ]
#       variable = "iam:PassedToService"
#     }
#   }
#   statement {
#     actions = [
#       "logs:CreateLogGroup",
#       "logs:CreateLogStream",
#       "logs:PutLogEvents",
#       "logs:PutRetentionPolicy",
#       "logs:DeleteLogStream",
#       "logs:DescribeLogGroups",
#       "logs:DescribeLogStreams"
#     ]
#     effect    = "Allow"
#     resources = ["arn:aws:logs:*:*:*"]
#   }
#   statement {
#     actions = [
#       "ec2:Describe*"
#     ]
#     effect    = "Allow"
#     resources = ["*"]
#   }
#   statement {
#     actions = [
#       "s3:Get*",
#       "s3:List*",
#       "s3:Put*"
#     ]
#     effect = "Allow"
#     resources = [
#       var.deployment_artifacts_s3_bucket_arn,
#       "${var.deployment_artifacts_s3_bucket_arn}/*",
#     ]
#   }
#   statement {
#     actions = [
#       "xray:PutTraceSegments",
#       "xray:PutTelemetryRecords",
#       "xray:GetSamplingRules",
#       "xray:GetSamplingTargets",
#       "xray:GetSamplingStatisticSummaries"
#     ]
#     effect    = "Allow"
#     resources = ["*"]
#     sid       = "ActiveTracing"
#   }
# }
