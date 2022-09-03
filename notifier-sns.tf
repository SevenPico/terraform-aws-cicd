# TODO - context

# ------------------------------------------------------------------------------
# Artifact Update SNS Topic
# ------------------------------------------------------------------------------
module "notifier_sns" {
  source  = "app.terraform.io/SevenPico/sns/aws"
  version = "1.0.0"
  context = module.context.self

  kms_master_key_id = ""
  pub_principals    = {} # var.sns_pub_principals
  sub_principals    = {} # var.sns_sub_principals
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
    # detail = {
    #   #pipeline = ["${module.context.id}-*"] # FIXME
    # }
  })

  # transformer = {
  #   template = <<EOF
  #   {
  #     "type": "ecr",
  #     "action": "update",
  #     "repository_name": "${each.key}",
  #     "repository_url": "${each.value}",
  #     "uri": "${each.value}:<tag>",
  #     "tag": <tag>
  #   }
  #   EOF
  #   paths = {
  #     tag = "$.detail.image-tag"
  #   }
  # }
}

# {
#     "version": "0",
#     "id": "01234567-EXAMPLE",
#     "detail-type": "CodePipeline Pipeline Execution State Change",
#     "source": "aws.codepipeline",
#     "account": "123456789012",
#     "time": "2020-01-24T22:03:07Z",
#     "region": "us-east-1",
#     "detail": {
#         "pipeline": "myPipeline",
#         "execution-id": "12345678-1234-5678-abcd-12345678abcd",
#         "execution-trigger": {
#             "trigger-type": "StartPipelineExecution",
#             "trigger-detail": "arn:aws:sts::123456789012:assumed-role/Admin/my-user"
#         },
#         "state": "STARTED",
#         "version": 1
#     }
# }
