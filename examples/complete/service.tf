/*
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "0.28.1"
  context = module.context.self

  cidr_block = "10.0.0.0/16"
}

module "subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "0.39.8"
  context = module.context.self

  availability_zones   = ["us-east-1a", "us-east-1b"]
  vpc_id               = module.vpc.vpc_id
  igw_id               = module.vpc.igw_id
  cidr_block           = module.vpc.vpc_cidr_block
  nat_gateway_enabled  = true
  nat_instance_enabled = false
}

resource "aws_ecs_cluster" "this" {
  name = module.context.id
  tags = module.context.tags
}

module "service" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.1"
  context = module.context.self
  name    = "service"

  alb_security_group                 = module.vpc.vpc_default_security_group_id
  container_definition_json          = module.container_definition.json_map_encoded_list
  ecs_cluster_arn                    = aws_ecs_cluster.this.arn
  launch_type                        = "FARGATE"
  vpc_id                             = module.vpc.vpc_id
  security_group_ids                 = [module.vpc.vpc_default_security_group_id]
  subnet_ids                         = module.subnets.public_subnet_ids
  ignore_changes_task_definition     = true
  network_mode                       = "awsvpc"
  assign_public_ip                   = true
  propagate_tags                     = "TASK_DEFINITION"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200
  deployment_controller_type         = "ECS"
  desired_count                      = 1
  task_cpu                           = 256
  task_memory                        = 512
  ecs_service_enabled                = true
}

module "container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_cpu                = 256
  essential                    = true
  container_image              = "nginxdemos/hello:latest"
  container_memory             = 256
  container_memory_reservation = 128
  container_name               = module.context.id
  readonly_root_filesystem     = false
  environment                  = []
  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]
}

# provider "aws" {
#   region = "us-east-1"
# }

# module "vpc" {
#   source  = "cloudposse/vpc/aws"
#   version = "0.18.2"
#   context = module.context.self

#   cidr_block = "10.0.0.0/16"
# }

# module "subnets" {
#   source  = "cloudposse/dynamic-subnets/aws"
#   version = "0.39.8"
#   context = module.context.self

#   availability_zones       = ["us-east-1a", "us-east-1b"]
#   vpc_id                   = module.vpc.vpc_id
#   igw_id                   = module.vpc.igw_id
#   cidr_block               = module.vpc.vpc_cidr_block
#   nat_gateway_enabled      = true
#   nat_instance_enabled     = false
#   aws_route_create_timeout = "5m"
#   aws_route_delete_timeout = "10m"
# }

# module "alb" {
#   source  = "cloudposse/alb/aws"
#   version = "0.27.0"
#   context = module.context.self

#   vpc_id                                  = module.vpc.vpc_id
#   security_group_ids                      = [module.vpc.vpc_default_security_group_id]
#   subnet_ids                              = module.subnets.public_subnet_ids
#   internal                                = false
#   http_enabled                            = true
#   access_logs_enabled                     = true
#   alb_access_logs_s3_bucket_force_destroy = true
#   cross_zone_load_balancing_enabled       = true
#   http2_enabled                           = true
#   deletion_protection_enabled             = false
# }

# resource "aws_ecs_cluster" "this" {
#   name = module.context.id
#   tags = module.context.tags
#   setting {
#     name  = "containerInsights"
#     value = "enabled"
#   }
# }

# module "service" {
#   source  = "cloudposse/ecs-web-app/aws"
#   version = "1.2.1"
#   context = module.context.self
#   name    = "service"

#   vpc_id                                          = module.vpc.vpc_id
#   ecs_private_subnet_ids                          = module.subnets.private_subnet_ids
#   ecs_cluster_arn                                 = aws_ecs_cluster.this.arn
#   ecs_cluster_name                                = aws_ecs_cluster.this.name
#   alb_arn_suffix                                  = module.alb.alb_arn_suffix
#   alb_security_group                              = module.alb.security_group_id
#   alb_ingress_unauthenticated_listener_arns       = [module.alb.http_listener_arn]
#   alb_ingress_unauthenticated_listener_arns_count = 1
#   codepipeline_enabled                            = false
#   webhook_enabled                                 = false
# }

*/
