module "ssm_context" {
  source     = "SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["deploy"]
  enabled = module.context.enabled && var.ssm_deploy_document_name == ""
}

resource "aws_ssm_document" "deployer" {
  count           = module.ssm_context.enabled ? 1 : 0
  name            = module.ssm_context.id
  document_format = "YAML"
  document_type   = "Command"
  tags            = module.ssm_context.tags
  content = templatefile("${path.module}/template/hello-world.tftpl", {})
}
