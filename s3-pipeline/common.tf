# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count = module.context.enabled ? 1 : 0

  name              = "/aws/codebuild/${module.context.id}"
  retention_in_days = var.cloudwatch_log_expiration_days
  tags              = module.context.tags
}

data "aws_region" "current" {
  count = module.context.enabled ? 1 : 0
}
