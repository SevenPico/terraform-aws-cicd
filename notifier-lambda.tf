# ------------------------------------------------------------------------------
# Notifier Lambda Context
# ------------------------------------------------------------------------------
module "notifier_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  enabled = module.context.enabled && var.slack_notifications_enabled
  attributes = ["notifier"]
}


# ------------------------------------------------------------------------------
# Notifier Lambda
# ------------------------------------------------------------------------------
module "notifier_lambda" {
  source     = "app.terraform.io/SevenPico/lambda-function/aws"
  version    = "0.1.0.2"
  context    = module.notifier_context.self
  attributes = ["lambda"]

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = null
  cloudwatch_logs_retention_in_days   = var.cloudwatch_log_expiration_days
  cloudwatch_log_subscription_filters = {}
  description                         = "Notify on Pipeline Events."
  event_source_mappings               = {}
  filename                            = data.archive_file.notifier_lambda[0].output_path
  function_name                       = module.notifier_context.id
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
  role_name                           = "${module.notifier_context.id}-role"
  runtime                             = "python3.9"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  source_code_hash                    = data.archive_file.notifier_lambda[0].output_sha
  ssm_parameter_names                 = null
  timeout                             = 60
  tracing_config_mode                 = null
  vpc_config                          = null

  lambda_environment = {
    variables = {
      SLACK_WEBHOOK_URL = var.slack_webhook_url
    }
  }
}

data "archive_file" "notifier_lambda" {
  count       = module.notifier_context.enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambdas/notifier"
  output_path = "${path.module}/.build/notifier-lambda.zip"
}


# ------------------------------------------------------------------------------
# Lambda SNS Subscription
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "notifier_lambda" {
  count = module.notifier_context.enabled ? 1 : 0

  endpoint  = module.notifier_lambda.arn
  protocol  = "lambda"
  topic_arn = module.notifier_sns.topic_arn
}

resource "aws_lambda_permission" "notifier_sns" {
  count = module.notifier_context.enabled ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = module.notifier_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.notifier_sns.topic_arn
  statement_id  = "AllowExecutionFromSNS"
}


# ------------------------------------------------------------------------------
# Lambda IAM
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "notifier_lambda" {
  count      = module.notifier_context.enabled ? 1 : 0
  depends_on = [module.notifier_lambda]

  role       = "${module.notifier_context.id}-role"
  policy_arn = module.notifier_lambda_policy.policy_arn
}

module "notifier_lambda_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  context = module.notifier_context.self

  description                   = "Notifier Lambda Access Policy"
  iam_override_policy_documents = null
  iam_policy_enabled            = true
  iam_policy_id                 = null
  iam_source_json_url           = null
  iam_source_policy_documents   = null

  iam_policy_statements = {
    # FIXME
    S3GetArtifact = {
      effect    = "Allow"
      actions   = ["s3:Get*"]
      resources = ["*"]
    }
  }
}


# ------------------------------------------------------------------------------
# Notifier DynamoDB Table
# ------------------------------------------------------------------------------
# module "notifier_table" {
#   source     = "cloudposse/dynamodb/aws"
#   version    = "0.29.5"
#   context    = module.notifier_context.self
#   attributes = ["table"]

#   hash_key       = "execution-id"
#   hash_key_type  = "S"
#   range_key      = ""
#   range_key_type = "S"

#   billing_mode                       = "PAY_PER_REQUEST"
#   enable_point_in_time_recovery      = false
#   enable_streams                     = false
#   global_secondary_index_map         = []
#   local_secondary_index_map          = []
#   replicas                           = []
#   stream_view_type                   = ""
#   tags_enabled                       = true
#   dynamodb_attributes                = []
#   ttl_attribute                      = "Expires"
#   ttl_enabled                        = true
#   enable_encryption                  = false
#   server_side_encryption_kms_key_arn = null
#   enable_autoscaler                  = false
#   autoscale_max_read_capacity        = 20
#   autoscale_max_write_capacity       = 20
#   autoscale_min_read_capacity        = 5
#   autoscale_min_write_capacity       = 5
#   autoscale_read_target              = 50
#   autoscale_write_target             = 50
#   autoscaler_attributes              = []
#   autoscaler_tags                    = {}
# }
