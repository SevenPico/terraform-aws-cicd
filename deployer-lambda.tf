# ------------------------------------------------------------------------------
# Deployer Lambda Context
# ------------------------------------------------------------------------------
module "deployer_context" {
  source     = "app.terraform.io/SevenPico/context/null"
  version    = "1.0.1"
  context    = module.context.self
  attributes = ["deployer"]
}

# ------------------------------------------------------------------------------
# S3 Deployer Artifacts Bucket Policy
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "deployer_artifacts_bucket" {
  count = module.context.enabled ? 1 : 0

  statement {
    sid       = "ForceSSLOnlyAccess"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [
      module.deployer_artifacts_bucket.bucket_arn,

    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
}


# ------------------------------------------------------------------------------
# Artifact Bucket for use by Deployer Lambda and Pipelines
# ------------------------------------------------------------------------------
module "deployer_artifacts_bucket" {
  source     = "app.terraform.io/SevenPico/s3-bucket/aws"
  version    = "3.1.8"
  context    = module.deployer_context.self
  attributes = ["artifacts"]

  acl                           = "private"
  allow_encrypted_uploads_only  = false
  allow_ssl_requests_only       = false
  block_public_acls             = true
  block_public_policy           = true
  bucket_key_enabled            = false
  bucket_name                   = null
  cors_rule_inputs              = null
  enable_mfa_delete             = var.enable_mfa_delete
  force_destroy                 = true # no unique data stored here
  grants                        = []
  ignore_public_acls            = true
  kms_master_key_arn            = ""
  lifecycle_configuration_rules = []
  logging = var.access_log_bucket_name != null && var.access_log_bucket_name != "" ? {
    bucket_name = var.access_log_bucket_name
    prefix      = var.access_log_bucket_prefix_override == null ? "${join("", data.aws_caller_identity.current[*].account_id)}/${module.context.id}/" : (var.access_log_bucket_prefix_override != "" ? "${var.access_log_bucket_prefix_override}/" : "")
  } : null
  object_lock_configuration     = null
  privileged_principal_actions  = []
  privileged_principal_arns     = []
  restrict_public_buckets       = true
  s3_object_ownership           = var.s3_object_ownership
  s3_replica_bucket_arn         = ""
  s3_replication_enabled        = false
  s3_replication_rules          = null
  s3_replication_source_roles   = []
  source_policy_documents       = [concat([one(data.aws_iam_policy_document.deployer_artifacts_bucket[*].json)], var.s3_source_policy_documents)
  sse_algorithm                 = "AES256"
  transfer_acceleration_enabled = false
  user_enabled                  = false
  versioning_enabled            = true
  website_inputs                = null
  allowed_bucket_actions = [
    "s3:PutObject",
    "s3:PutObjectAcl",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:ListBucket",
    "s3:ListBucketMultipartUploads",
    "s3:GetBucketLocation",
    "s3:AbortMultipartUpload"
  ]
}


# ------------------------------------------------------------------------------
# Deployer Lambda
# ------------------------------------------------------------------------------
module "deployer_lambda" {
  source     = "app.terraform.io/SevenPico/lambda-function/aws"
  version    = "0.1.0.2"
  context    = module.deployer_context.self
  attributes = ["lambda"]

  architectures                       = null
  cloudwatch_event_rules              = {}
  cloudwatch_lambda_insights_enabled  = false
  cloudwatch_logs_kms_key_arn         = module.kms_key.key_arn
  cloudwatch_logs_retention_in_days   = var.cloudwatch_log_expiration_days
  cloudwatch_log_subscription_filters = {}
  description                         = "Trigger Deployment Pipelines on Artifact Update Notification."
  event_source_mappings               = {}
  filename                            = data.archive_file.deployer_lambda[0].output_path
  function_name                       = module.deployer_context.id
  handler                             = "main.lambda_handler"
  ignore_external_function_updates    = false
  image_config                        = {}
  image_uri                           = null
  kms_key_arn                         = module.kms_key.key_arn
  lambda_at_edge                      = false
  layers                              = []
  memory_size                         = 128
  package_type                        = "Zip"
  publish                             = false
  reserved_concurrent_executions      = -1
  role_name                           = "${module.deployer_context.id}-role"
  runtime                             = "python3.9"
  s3_bucket                           = null
  s3_key                              = null
  s3_object_version                   = null
  sns_subscriptions                   = {}
  source_code_hash                    = data.archive_file.deployer_lambda[0].output_base64sha256
  ssm_parameter_names                 = null
  timeout                             = 60
  tracing_config_mode                 = null
  vpc_config                          = null

  lambda_environment = {
    variables = {
      DEPLOYER_ARTIFACTS_BUCKET_ID = module.deployer_artifacts_bucket.bucket_id
      TARGET_NAMES                 = join(",", keys(local.targets))
    }
  }
}

data "archive_file" "deployer_lambda" {
  count       = module.deployer_context.enabled ? 1 : 0
  type        = "zip"
  source_dir  = "${path.module}/lambdas/deployer"
  output_path = "${path.module}/.build/deployer-lambda.zip"
}


# ------------------------------------------------------------------------------
# Lambda SNS Subscription
# ------------------------------------------------------------------------------
resource "aws_sns_topic_subscription" "deployer_lambda" {
  count = module.deployer_context.enabled ? 1 : 0

  endpoint  = module.deployer_lambda.arn
  protocol  = "lambda"
  topic_arn = var.artifact_sns_topic_arn
}

resource "aws_lambda_permission" "artifact_sns" {
  count = module.deployer_context.enabled ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = module.deployer_lambda.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = var.artifact_sns_topic_arn
  statement_id  = "AllowExecutionFromSNS"
}

resource "aws_lambda_permission" "target_source_update_event" {
  count = module.deployer_context.enabled ? 1 : 0

  action        = "lambda:InvokeFunction"
  function_name = module.deployer_lambda.function_name
  principal     = "events.amazonaws.com"
  statement_id  = "AllowExecutionFromCloudWatch"
  source_arn    = module.ssm_target_source_update_event.rule_arn
}


# ------------------------------------------------------------------------------
# Lambda IAM
# ------------------------------------------------------------------------------
resource "aws_iam_role_policy_attachment" "deployer_lambda" {
  count      = module.deployer_context.enabled ? 1 : 0
  depends_on = [module.deployer_lambda]

  role       = "${module.deployer_context.id}-role"
  policy_arn = module.deployer_lambda_policy.policy_arn
}

module "deployer_lambda_policy" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"
  context = module.deployer_context.self

  description                   = "Deployer Lambda Access Policy"
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
        "ssm:GetParameters",
        "ssm:DescribeParameter*",
      ]
      resources = [
        for p in aws_ssm_parameter.target_source : p.arn
      ]
    }
    KmsSsmDecrypt = {
      effect    = "Allow"
      actions   = ["kms:Decrypt", "kms:DescribeKey"]
      resources = [module.kms_key.key_arn]
    }
    S3PutArtifact = {
      effect  = "Allow"
      actions = ["s3:PutObject"]
      resources = [
        module.deployer_artifacts_bucket.bucket_arn,
        "${module.deployer_artifacts_bucket.bucket_arn}/*",
      ]
    }
    S3GetArtifact = {
      effect    = "Allow"
      actions   = ["s3:Get*"]
      resources = ["*"] # FIXME s3_targets.target_s3_bucket_id
    }
  }
}
