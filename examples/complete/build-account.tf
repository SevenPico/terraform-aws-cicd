# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "artifact_bucket" {
  source     = "app.terraform.io/SevenPico/s3-bucket/aws"
  version    = "3.0.0"
  context    = module.context.self
  attributes = ["artifacts"]
}


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "ecr" {
  source = "registry.terraform.io/cloudposse/ecr/aws"
  version = "0.34.0"
  context = module.context.self
  name    = "ecr"

  enable_lifecycle_policy    = true
  encryption_configuration   = null
  image_names                = ["foo"]
  image_tag_mutability       = "MUTABLE"
  max_image_count            = 1000
  principals_full_access     = []
  principals_readonly_access = []
  principals_lambda          = []
  protected_tags             = []
  scan_images_on_push        = true
  use_fullname               = false
}


# ------------------------------------------------------------------------------
# Artifact Monitor
# ------------------------------------------------------------------------------
module "artifact_monitor" {
  source  = "../../artifact-monitor"
  context = module.context.self

  ecr_repository_url_map = module.ecr.repository_url_map
  s3_bucket_ids          = [module.artifact_bucket.bucket_id]
}

resource "aws_sns_topic_subscription" "test" {
  endpoint  = "brad+test@7pi.co"
  protocol  = "email"
  topic_arn = module.artifact_monitor.sns_topic_arn
}
