# Store terraform state remotely on terraform cloud
terraform {
  backend "remote" {
    hostname      = "app.terraform.io"
    organization  = "blokaly"

    workspaces {
      name = "test"
    }
  }
}

provider "aws" {
  region = "ap-east-1"
  profile = "default"
}

# 1. Create VPC
resource "aws_vpc" "production-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

# 2. Create Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.production-vpc.id
}

# 3. Create Custom Route Table
resource "aws_route_table" "prod-route-table" {
  vpc_id = aws_vpc.production-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "prod"
  }
}

# 4. Create a Subnet

variable "subnet_prefix" {
  description = "cidr block for the subnet"
}

resource "aws_subnet" "subnet-1" {
  cidr_block = var.subnet_prefix[0].cidr_block
  vpc_id = aws_vpc.production-vpc.id
  availability_zone = "ap-east-1a"

  tags = {
    Name = var.subnet_prefix[0].name
  }
}

resource "aws_subnet" "subnet-2" {
  cidr_block = var.subnet_prefix[1].cidr_block
  vpc_id = aws_vpc.production-vpc.id
  availability_zone = "ap-east-1a"

  tags = {
    Name = var.subnet_prefix[1].name
  }
}

# 5. Associate subnet with Route Table
resource "aws_route_table_association" "a" {
  route_table_id = aws_route_table.prod-route-table.id
  subnet_id = aws_subnet.subnet-1.id
}

# 6. Create Security Group to allow port 22/80,443
resource "aws_security_group" "allow-web" {
  vpc_id = aws_vpc.production-vpc.id
  name = "allow_web_traffic"
  description = "Allow Web inbound traffic"

  # allow ingress of port 443
  ingress {
    description = "HTTPS"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    to_port = 443
    protocol = "tcp"
  }

  ingress {
    description = "HTTP"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 80
    to_port = 80
    protocol = "tcp"
  }

  ingress {
    description = "SSH"
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 22
    to_port = 22
    protocol = "tcp"
  }


  # allow egress of all ports
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_web"
  }
}

# 7. Create a network interface with an ip in the subnet that was created in step 4
resource "aws_network_interface" "web-server-nic" {
  subnet_id       = aws_subnet.subnet-1.id
  private_ips     = ["10.0.1.50"]
  security_groups = [aws_security_group.allow-web.id]
}

# 8. Assign an elastic IP to the network interface created in step 7
resource "aws_eip" "one" {
  vpc = true
  network_interface = aws_network_interface.web-server-nic.id
  associate_with_private_ip = "10.0.1.50"
  depends_on = [aws_internet_gateway.gw]
}

output "server_public_ip" {
  value = aws_eip.one.public_ip
}

# 9. Create Ubuntu server and install/enable apache2
resource "aws_instance" "web-server-instance" {
  ami = "ami-81e2a0f0"
  instance_type = "t3.micro"
  availability_zone = "ap-east-1a"
  key_name = "mykey"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.web-server-nic.id
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo systemctl start apache2
              sudo bash -c 'echo your very first web server > /var/www/html/index.html'
              EOF
  tags = {
    Name = "web-server"
  }
}

output "server_private_ip" {
  value = aws_instance.web-server-instance.private_ip
}

output "server_id" {
  value = aws_instance.web-server-instance.id
}