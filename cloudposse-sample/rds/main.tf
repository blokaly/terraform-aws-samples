provider "aws" {
  region = "ap-southeast-1"
}

data "aws_vpc" "default" {
  tags = {
    Name = "my-test-vpc"
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.default.id

  tags = {
    Attributes = "private"
  }
}

data "aws_subnet" "private-subnet" {
  for_each = data.aws_subnet_ids.private.ids
  id       = each.value
}

data "aws_security_group" "default-sg" {
  vpc_id = data.aws_vpc.default.id
}

module "rds_cluster" {
  source          = "git::https://github.com/cloudposse/terraform-aws-rds-cluster.git?ref=tags/0.36.0"
  engine          = var.engine
  engine_mode     = var.engine_mode
  cluster_family  = var.cluster_family
  cluster_size    = var.cluster_size
  namespace       = var.namespace
  stage           = var.stage
  name            = var.name
  admin_user      = var.admin_user
  admin_password  = var.admin_password
  db_name         = var.db_name
  db_port         = 5432
  instance_type   = var.instance_type
  vpc_id          = data.aws_vpc.default.id
  security_groups = [data.aws_security_group.default-sg.id]
  subnets         = data.aws_subnet_ids.private.ids
  deletion_protection = var.deletion_protection
  autoscaling_enabled = var.autoscaling_enabled
  # enable monitoring every 30 seconds
  rds_monitoring_interval = var.rds_monitoring_interval
  enhanced_monitoring_role_enabled = var.enhanced_monitoring_role_enabled

  context = module.this.context
}