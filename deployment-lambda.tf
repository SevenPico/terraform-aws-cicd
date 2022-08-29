# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "deployment_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["deployment"]
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "deployment_bucket" {
  source     = "app.terraform.io/SevenPico/s3-bucket/aws"
  version    = "3.0.0"
  context    = module.deployment_context.self
  attributes = ["bucket"]
  # FIXME
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "deployment_lambda" {
  source     = "app.terraform.io/SevenPico/lambda-function/aws"
  version    = "0.1.0.2"
  context    = module.deployment_context.self
  attributes = ["lambda"]

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = null
  cloudwatch_logs_retention_in_days   = var.cloudwatch_log_expiration_days
  cloudwatch_log_subscription_filters = {}
  description                         = "Trigger Deployment Pipelines on Artifact Update Notification."
  event_source_mappings               = {}
  filename                            = data.archive_file.deployment_lambda[0].output_path
  function_name                       = module.deployment_context.id
  handler                             = "main.lambda_handler"
  ignore_external_function_updates    = false
  image_config                        = {}
  image_uri                           = null
  kms_key_arn                         = ""
  lambda_at_edge                      = false
  layers                              = []
  memory_size                         = 128
  package_type                        = "Zip"
  publish                             = false
  reserved_concurrent_executions      = -1
  role_name                           = "${module.deployment_context.id}-role"
  runtime                             = "python3.9"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  source_code_hash                    = data.archive_file.deployment_lambda[0].output_sha
  ssm_parameter_names                 = null
  timeout                             = 3
  tracing_config_mode                 = null
  vpc_config                          = null

  lambda_environment = {
    variables = {
      DEPLOYMENT_BUCKET_ID = module.deployment_bucket.bucket_id
      TARGET_NAMES         = join(",", keys(var.ecs_targets))
    }
  }
}

data "archive_file" "deployment_lambda" {
  count       = module.deployment_context.enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/deployment_lambda"
  output_path = "${path.module}/.build/deployment_lambda.zip"
}


# ------------------------------------------------------------------------------
# Lambda SNS Subscription
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "deployment_lambda" {
  count = module.deployment_context.enabled ? 1 : 0

  endpoint  = module.deployment_lambda.arn
  protocol  = "lambda"
  topic_arn = var.artifact_sns_topic_arn
}

resource "aws_lambda_permission" "artifact_sns" {
  count = module.deployment_context.enabled ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = module.deployment_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.artifact_sns_topic_arn
  statement_id  = "AllowExecutionFromSNS"
}


# ------------------------------------------------------------------------------
# Lambda IAM
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "lambda" {
  count      = module.deployment_context.enabled ? 1 : 0
  role       = "${module.deployment_context.id}-role"
  policy_arn = module.deployment_lambda_policy.policy_arn
}

module "deployment_lambda_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  context = module.context.self

  description                   = "Deployment Lambda Access Policy"
  iam_override_policy_documents = null
  iam_policy_enabled            = true
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null

  iam_policy_statements = {
    SsmGetParameters = {
      effect = "Allow"
      actions = [
        "ssm:GetParameter*",
        "ssm:DescribeParameter*",
      ]
      resources = concat(
        aws_ssm_parameter.ecs_source[*].arn,
        # aws_ssm_parameter.s3_source[*].arn,
      )
    }
    S3PutArtifact = {
      effect    = "Allow"
      actions   = ["s3:Put*"]
      resources = [module.deployment_bucket.bucket_id]
    }
    S3GetArtifact = {
      effect    = "Allow"
      actions   = ["s3:Get*"]
      resources = [var.artifact_bucket_id]
    }
  }
}
