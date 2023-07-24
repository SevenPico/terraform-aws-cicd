# ------------------------------------------------------------------------------
# Cloudformation Stack
# ------------------------------------------------------------------------------
module "cloudformation_stack" {
  source     = "registry.terraform.io/SevenPico/cloudformation-stack/aws"
  version    = "1.0.0"
  context    = module.context.self
  enabled    = module.context.enabled
  attributes = ["cloudformation"]
  depends_on = [aws_s3_object.template_file]

  parameters         = {}
  capabilities       = ["CAPABILITY_NAMED_IAM", "CAPABILITY_IAM"]
  on_failure         = "ROLLBACK"
  policy_body        = ""
  template_url       = "https://${module.build_artifacts_bucket.bucket_id}.s3.amazonaws.com/${aws_s3_object.template_file[0].key}"
  template_body      = ""
  timeout_in_minutes = 30
}