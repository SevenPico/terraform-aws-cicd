# ------------------------------------------------------------------------------
# EC2 Pipelines
# ------------------------------------------------------------------------------
locals {
  ssm_deploy_document_name = var.ssm_deploy_document_name == "" ? try(aws_ssm_document.deployer[0].name, "") : var.ssm_deploy_document_name
  buildspec                = var.buildspec != "" ? var.buildspec : <<EOF
version: 0.2
phases:
  install:
    runtime-versions:
      python: 3.8
    commands:
      - echo "Installing AWS CLI"
      - pip install --upgrade awscli
  build:
    commands:
      - echo "Running SSM document on EC2 instances"
      - aws ssm send-command --document-name "${SSM_DOCUMENT_NAME}" --targets "Key=tag:${TARGET_KEY},Values=${TARGET_KEY_VALUES}"
EOF
  buildspec_env_vars = var.buildspec_env_vars != [] ? var.buildspec_env_vars : [
    {
      name  = "TARGET_KEY"
      value = "${var.ssm_document_target_key_name}"
      type  = "PLAINTEXT"
    },
    {
      name  = "TARGET_KEY_VALUES"
      value = "${var.ssm_document_target_key_values}"
      type  = "PLAINTEXT"
    },
    {
      name  = "SSM_DOCUMENT_NAME"
      value = local.ssm_deploy_document_name
      type  = "PLAINTEXT"
    },
  ]
  buildspec_policy_docs = var.buildspec_policy_docs != [] ? var.buildspec_policy_docs : data.aws_iam_policy_document.build_access_policy_doc.*.json
}

module "ec2_pipeline" {
  source  = "../../"
  context = module.context.self

  attributes = ["cicd"]

  artifact_sns_topic_arn          = var.artifact_sns_topic_arn
  build_image                     = var.build_image
  cloudwatch_log_expiration_days  = var.cloudwatch_log_expiration_days
  create_kms_key                  = true
  ecs_deployment_timeout          = 15 # min
  enable_mfa_delete               = false
  kms_key_deletion_window_in_days = var.kms_key_deletion_window_in_days
  kms_key_enable_key_rotation     = var.kms_key_enable_key_rotation
  overwrite_ssm_parameters        = var.overwrite_ssm_parameters
  s3_source_policy_documents      = []
  slack_channel_ids               = var.slack_channel_ids
  slack_notifications_enabled     = var.slack_notifications_enabled
  slack_token_secret_arn          = var.slack_token_secret_arn
  slack_token_secret_kms_key_arn  = var.slack_token_secret_kms_key_arn
  ecs_targets                     = {}
  s3_targets                      = {}
  ec2_targets = {
    source_s3_bucket_id  = module.deployer_artifacts_bucket.bucket_id
    source_s3_object_key = "ec2/demo.txt"
    build = {
      buildspec   = local.buildspec
      env_vars    = local.buildspec_env_vars
      policy_docs = local.buildspec_policy_docs
    }
  }
}


# ------------------------------------------------------------------------------
# Build Access IAM policy Document
# ------------------------------------------------------------------------------
data "aws_iam_policy_document" "build_access_policy_doc" {
  count = module.context.enabled && length(var.buildspec_policy_docs) == 0 ? 1 : 0

  statement {
    effect = "Allow"
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Put*"
    ]
    resources = [
      module.deployer_artifacts_bucket.bucket_arn
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ssm:SendCommand"
    ]
    resources = [aws_ssm_document.deployer[0].arn]
  }
}