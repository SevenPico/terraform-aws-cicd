// service a
// service b
// site a
// site b
// lambda
// api

# deployment



# module "cicd" {
#   artifact_monitor_sns_topic_arns = [module.artifact_monitor.sns_topic_arn]

#   targets = {
#     foo-service = {
#       type             = "ecs"
#       image_uri        = "249974707517.dkr.ecr.us-east-1.amazonaws.com/foo:latest"
#       ecs_cluster_name = ""
#       ecs_service_name = ""
#     }
#     bar-site = {
#       type             = "s3-website"
#       origin_bucket_id = module.order_site.s3_bucket
#       s3_path          = "${var.artifacts_bucket_id}/sites/bar/bar-latest.zip"
#     }
#   }
# }



/*
module "ecs_service_cicd" {
  source  = "../"
  context = module.context.self
  name    = "cicd"

  ecs_cluster_name = aws_ecs_cluster.this.name
  ecs_service_name = module.service.service_name

  image_detail_s3_bucket_id  = "" #FIXME
  image_detail_s3_object_key = "" #FIXME

  artifact_store_kms_key_id       = ""
  artifact_store_s3_bucket_id     = ""
  cloudwatch_log_expiration_days  = 90
  create_artifact_store_s3_bucket = true
  ecs_deployment_timeout          = 15
}

module "artifacts_bucket" {
  source = "../../artifacts-bucket"
  #version = "FIXME"
  context = module.context.self
  name    = "artifacts"

  read_principals = [module.ecs_service_cicd.role_arn]
  rorce_destroy   = true
}


*/
