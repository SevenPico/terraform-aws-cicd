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

module "foo_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_cpu                = 256
  essential                    = true
  container_image              = "nginxdemos/hello:latest"
  container_memory             = 256
  container_memory_reservation = 128
  container_name               = "foo"
  readonly_root_filesystem     = false
  environment                  = []
  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]
}

module "foo_service" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.1"
  name    = "foo-service"

  alb_security_group                 = module.vpc.vpc_default_security_group_id
  container_definition_json          = module.foo_container_definition.json_map_encoded_list
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


module "bar_container_definition" {
  source  = "cloudposse/ecs-container-definition/aws"
  version = "0.58.1"

  container_cpu                = 256
  essential                    = true
  container_image              = "nginxdemos/hello:latest"
  container_memory             = 256
  container_memory_reservation = 128
  container_name               = "bar"
  readonly_root_filesystem     = false
  environment                  = []
  port_mappings = [{
    containerPort = 80
    hostPort      = 80
    protocol      = "tcp"
  }]
}


module "bar_service" {
  source  = "cloudposse/ecs-alb-service-task/aws"
  version = "0.66.1"
  name    = "bar-service"

  alb_security_group                 = module.vpc.vpc_default_security_group_id
  container_definition_json          = module.bar_container_definition.json_map_encoded_list
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
