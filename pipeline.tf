


module "pipeline" {
  source  = "./pipeline"
  context = module.context.self

  for_each = var.targets

  type = each.value.type

  cloudwatch_log_expiration_days = var.cloudwatch_log_expiration_days
}
