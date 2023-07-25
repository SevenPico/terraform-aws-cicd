#------------------------------------------------------------------------------
# EC2 Cloudwatch Log Group
#------------------------------------------------------------------------------
resource "aws_cloudwatch_log_group" "ec2_autoscale_group" {
  count             = module.context.enabled ? 1 : 0
  name              = "/aws/ec2/${module.context.id}"
  retention_in_days = var.cloudwatch_log_expiration_days
}


#------------------------------------------------------------------------------
# EC2 ASG IAM
#------------------------------------------------------------------------------
module "ec2_role_context" {
  source     = "registry.terraform.io/SevenPico/context/null"
  version    = "2.0.0"
  context    = module.context.self
  attributes = ["ec2", "role"]
}

data "aws_iam_policy_document" "ec2_autoscale_group_policy_doc" {
  count = module.context.enabled ? 1 : 0

  statement {
    actions = [
      "ec2:Describe*"
    ]
    effect    = "Allow"
    resources = ["*"]
  }
}

module "ec2_autoscale_group_role" {
  source  = "registry.terraform.io/SevenPicoForks/iam-role/aws"
  version = "2.0.0"
  context = module.ec2_role_context.self

  assume_role_actions      = ["sts:AssumeRole"]
  assume_role_conditions   = []
  instance_profile_enabled = false
  managed_policy_arns      = ["arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"]
  max_session_duration     = 3600
  path                     = "/"
  permissions_boundary     = ""
  policy_description       = "Ec2 Server Permissions"
  policy_document_count    = 1
  policy_documents         = try(data.aws_iam_policy_document.ec2_autoscale_group_policy_doc[*].json, [])
  principals = {
    Service : [
      "ec2.amazonaws.com",
      "ssm.amazonaws.com",
    ]
  }
  role_description = "IAM role with permissions to perform actions required by the Ec2 instance"
  use_fullname     = true
}

resource "aws_iam_instance_profile" "ec2_autoscale_group_instance_profile" {
  count = module.ec2_role_context.enabled ? 1 : 0
  name  = "${module.ec2_role_context.id}-instance-profile"
  role  = module.ec2_autoscale_group_role.name
}


#------------------------------------------------------------------------------
# EC2 Auto Scale Group
#------------------------------------------------------------------------------
module "ec2_autoscale_group" {
  source  = "registry.terraform.io/SevenPicoForks/ec2-autoscale-group/aws"
  version = "2.0.6"
  context = module.context.self
  tags    = { (var.ssm_document_target_key_name) : var.ssm_document_target_key_values }

  instance_type    = var.ec2_autoscale_instance_type
  max_size         = 3
  min_size         = 1
  desired_capacity = 1
  subnet_ids       = module.vpc_subnets.private_subnet_ids

  associate_public_ip_address             = true
  autoscaling_policies_enabled            = false
  block_device_mappings                   = []
  capacity_rebalance                      = false
  cpu_utilization_high_evaluation_periods = 2
  cpu_utilization_high_period_seconds     = 300
  cpu_utilization_high_statistic          = "Average"
  cpu_utilization_high_threshold_percent  = 90
  cpu_utilization_low_evaluation_periods  = 2
  cpu_utilization_low_period_seconds      = 300
  cpu_utilization_low_statistic           = "Average"
  cpu_utilization_low_threshold_percent   = 10
  credit_specification                    = null
  custom_alarms                           = {}
  default_alarms_enabled                  = true
  default_cooldown                        = 300
  disable_api_termination                 = false
  ebs_optimized                           = false
  elastic_gpu_specifications              = null
  enable_monitoring                       = true
  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  force_delete                         = false
  health_check_grace_period            = 300
  health_check_type                    = "EC2"
  iam_instance_profile_name            = join("", aws_iam_instance_profile.ec2_autoscale_group_instance_profile.*.name)
  image_id                             = "ami-0574da719dca65348"
  instance_initiated_shutdown_behavior = "terminate"
  instance_market_options              = null
  instance_refresh                     = null
  key_name                             = ""
  launch_template_version              = "$Latest"
  load_balancers                       = []
  max_instance_lifetime                = null
  metadata_http_endpoint_enabled       = true
  metadata_http_put_response_hop_limit = 2
  metadata_http_tokens_required        = true
  metrics_granularity                  = "1Minute"
  min_elb_capacity                     = 0
  mixed_instances_policy               = null
  placement                            = null
  placement_group                      = ""
  protect_from_scale_in                = false
  scale_down_adjustment_type           = "ChangeInCapacity"
  scale_down_cooldown_seconds          = 300
  scale_down_policy_type               = "SimpleScaling"
  scale_down_scaling_adjustment        = -1
  scale_up_adjustment_type             = "ChangeInCapacity"
  scale_up_cooldown_seconds            = 300
  scale_up_policy_type                 = "SimpleScaling"
  scale_up_scaling_adjustment          = 1
  security_group_ids                   = [module.ec2_autoscale_group_sg.id]
  service_linked_role_arn              = ""
  suspended_processes                  = []
  tag_specifications_resource_types = [
    "instance",
    "volume"
  ]
  target_group_arns         = []
  termination_policies      = ["Default"]
  user_data_base64          = base64encode("")
  wait_for_capacity_timeout = "10m"
  wait_for_elb_capacity     = 0
  warm_pool                 = null

}


#------------------------------------------------------------------------------
# EC2 Auto Scale Security Group
#------------------------------------------------------------------------------
module "ec2_autoscale_group_sg" {
  source     = "registry.terraform.io/SevenPicoForks/security-group/aws"
  version    = "3.0.0"
  context    = module.context.self
  attributes = ["ec2"]

  allow_all_egress           = true
  create_before_destroy      = false
  inline_rules_enabled       = false
  preserve_security_group_id = true
  revoke_rules_on_delete     = false
  rule_matrix                = []
  rules = [
    {
      key                      = "IngressOn443"
      description              = "Allow ingress on 443."
      type                     = "ingress"
      protocol                 = "tcp"
      from_port                = 443
      to_port                  = 443
      cidr_blocks              = ["0.0.0.0/0"]
      source_security_group_id = null
    }
  ]
  rules_map                     = {}
  security_group_create_timeout = "10m"
  security_group_delete_timeout = "15m"
  security_group_description    = "Ec2 Service Security Group"
  security_group_name           = []
  target_security_group_id      = []
  vpc_id                        = module.vpc.vpc_id
}
