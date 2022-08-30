# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
module "cicd" {
  source  = "../../"
  context = module.context.self
  name    = "cicd"

  artifact_bucket_id             = module.artifact_bucket.bucket_id
  artifact_sns_topic_arn         = module.artifact_monitor.sns_topic_arn
  cloudwatch_log_expiration_days = 90
  ecs_deployment_timeout         = 15

  ecs_targets = {
    foo = {
      image_uri          = "${module.ecr.repository_url_map["foo"]}:latest"
      ecs_cluster_name   = aws_ecs_cluster.this.name
      ecs_service_name   = module.foo_service.service_name
    }
    bar = {
      image_uri        = "${module.ecr.repository_url_map["bar"]}:latest"
      ecs_cluster_name = aws_ecs_cluster.this.name
      ecs_service_name = module.bar_service.service_name
    }
  }
}
