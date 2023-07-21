## ----------------------------------------------------------------------------
##  Copyright 2023 SevenPico, Inc.
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.
## ----------------------------------------------------------------------------

## ----------------------------------------------------------------------------
##  ./examples/complete/ecs-service.tf
##  This file contains code written by SevenPico, Inc.
## ----------------------------------------------------------------------------

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
  subnet_ids                         = module.vpc_subnets.public_subnet_ids
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
  subnet_ids                         = module.vpc_subnets.public_subnet_ids
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
