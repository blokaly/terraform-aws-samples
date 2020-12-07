provider "aws" {
  version = "~> 2.0"
  region = "ap-east-1"
  profile = "default"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["*amazon-ecs-optimized"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs = ["ap-east-1a", "ap-east-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

module "security_group" {
  source = "terraform-aws-modules/security-group/aws"
  version = "~> 3.0"

  name = "my-security-group"
  description = "Security group for example usage with EC2 instance"
  vpc_id = module.vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules = ["ssh-22-tcp", "all-icmp"]
  egress_rules = ["all-all"]
}

module "ec2_with_t3_nano" {
  source = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  instance_count = 1
  name = "my-t3-nano"

  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  monitoring = true
  subnet_id = element(module.vpc.private_subnets, 0)
  vpc_security_group_ids = [module.security_group.this_security_group_id]
  associate_public_ip_address = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}