vpc_cidr = "10.0.0.0/16"

environment = "acc"

public_subnet_cidrs = ["10.0.0.0/24", "10.0.1.0/24"]

private_subnet_cidrs = ["10.0.50.0/24", "10.0.51.0/24"]

availability_zones = ["ap-east-1a", "ap-east-1b"]

max_size = 1

min_size = 1

desired_capacity = 1

instance_type = "t3.nano"

ecs_aws_ami = "ami-7284c903"
