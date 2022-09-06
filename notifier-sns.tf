# ------------------------------------------------------------------------------
# Artifact Update SNS Topic
# ------------------------------------------------------------------------------
module "notifier_sns" {
  source  = "app.terraform.io/SevenPico/sns/aws"
  version = "1.0.0"
  context = module.context.self

  kms_master_key_id = ""
  pub_principals    = {}
  sub_principals    = {}
}


# ------------------------------------------------------------------------------
# CodePipeline Event Rule
# ------------------------------------------------------------------------------
module "codepipeline_event" {
  source  = "app.terraform.io/SevenPico/events/aws//cloudwatch-event"
  version = "0.0.1"
  context = module.context.self

  description = "CodePipeline Events"
  target_arn  = module.notifier_sns.topic_arn

  event_pattern = jsonencode({
    source      = ["aws.codepipeline"]
    detail-type = ["CodePipeline Pipeline Execution State Change"]
    detail = {
      pipeline = ["${module.context.id}-*"]
    }
  })
}
