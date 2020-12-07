provider "aws" {
  version = "~> 2.0"
  region = "ap-east-1"
  profile = "default"
}

resource "aws_key_pair" "my-key" {
  key_name   = "my-key"
  public_key = file("key.pub")
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

resource "aws_security_group" "my-security-group" {
  name        = "my-security-group"
  description = "Allow HTTP, HTTPS and SSH traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform"
  }
}

resource "aws_instance" "my-t3-nano" {

  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3.nano"
  key_name = aws_key_pair.my-key.key_name
  monitoring = true
  subnet_id = element(module.vpc.public_subnets, 0)
  vpc_security_group_ids = [aws_security_group.my-security-group.id]
  associate_public_ip_address = true

  connection {
    type     = "ssh"
    user     = "ec2-user"
    private_key = file("key")
    host     = self.public_ip
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

output "ip" {
  value = aws_instance.my-t3-nano.*.public_ip
}