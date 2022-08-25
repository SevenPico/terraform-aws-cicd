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


module "ecr" {
  source  = "registry.terraform.io/cloudposse/ecr/aws"
  version = "0.34.0"
  # source  = "../../terraform-aws-ecr"
  context = module.context.self
  name    = "ecr"

  enable_lifecycle_policy    = true
  encryption_configuration   = null
  image_names                = [module.context.id]
  image_tag_mutability       = "MUTABLE"
  max_image_count            = 1000
  principals_full_access     = []
  principals_readonly_access = [] #module.ecs_service_cicd.role_arn]
  principals_lambda          = []
  protected_tags             = []
  scan_images_on_push        = true
  use_fullname               = false
}


