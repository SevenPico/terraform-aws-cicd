module "cicd" {
  source  = "../../"
  context = module.context.self
  name    = "cicd"

  artifact_bucket_id     = module.artifact_bucket.bucket_id
  artifact_sns_topic_arn = module.artifact_monitor.sns_topic_arn

  ecs_targets = {
    foo = {
      image_uri        = "${module.ecr.repository_url_map["foo"]}:latest"
      ecs_cluster_name = aws_ecs_cluster.this.name
      ecs_service_name = module.foo_service.service_name
    }
    bar = {
      image_uri        = "${module.ecr.repository_url_map["bar"]}:latest"
      ecs_cluster_name = aws_ecs_cluster.this.name
      ecs_service_name = module.bar_service.service_name
    }
  }

  s3_targets = {
    foo = {
      source_s3_bucket_id  = module.artifact_bucket.bucket_id
      source_s3_object_key = "sites/foo/foo-latest.zip"
      target_s3_bucket_id  = module.site_bucket["foo"].bucket_id
      pre_deploy = {
        buildspec   = "deployspec.yml"
        permissions = []
        env_vars    = []
      }
    }
    bar = {
      source_s3_bucket_id  = module.artifact_bucket.bucket_id
      source_s3_object_key = "sites/bar/bar-latest.zip"
      target_s3_bucket_id  = module.site_bucket["bar"].bucket_id
      pre_deploy           = null
    }
  }
}
