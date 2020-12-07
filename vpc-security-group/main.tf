provider "aws" {
  version = "~> 2.0"
  region = "ap-east-1"
  profile = "default"
}

# create the VPC
resource "aws_vpc" "my-vpc" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "My VPC"
  }
}

# create the Subnet
resource "aws_subnet" "my-vpc-subnet" {
  vpc_id = aws_vpc.my-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "ap-east-1a"
  tags = {
    Name = "My VPC Subnet"
  }
}

# Create the Security Group
resource "aws_security_group" "my-vpc-security-group" {
  vpc_id = aws_vpc.my-vpc.id
  name = "My VPC Security Group"
  description = "My VPC Security Group"

  # allow ingress of port 443
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    from_port = 443
    to_port = 443
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
    Name = "My VPC Security Group"
    Description = "My VPC Security Group"
  }
}

# create VPC Network access control list
resource "aws_network_acl" "my-vpc-security_acl" {
  vpc_id = aws_vpc.my-vpc.id
  subnet_ids = [aws_subnet.my-vpc-subnet.id]
  # allow ingress port 443
  ingress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  # allow ingress port 80
  ingress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  # allow ingress ephemeral ports
  ingress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }

  # allow egress port 443
  egress {
    protocol = "tcp"
    rule_no = 100
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 443
    to_port = 443
  }

  # allow egress port 80
  egress {
    protocol = "tcp"
    rule_no = 200
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 80
    to_port = 80
  }

  # allow egress ephemeral ports
  egress {
    protocol = "tcp"
    rule_no = 300
    action = "allow"
    cidr_block = "0.0.0.0/0"
    from_port = 1024
    to_port = 65535
  }
  tags = {
    Name = "My VPC ACL"
  }
}

# Create the Internet Gateway
resource "aws_internet_gateway" "my-vpc-gateway" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "My VPC Internet Gateway"
  }
}

# Create the Route Table
resource "aws_route_table" "my-vpc-route-table" {
  vpc_id = aws_vpc.my-vpc.id
  tags = {
    Name = "My VPC Route Table"
  }
}

# Create the Internet Access
resource "aws_route" "my-vpc-internet-access" {
  route_table_id = aws_route_table.my-vpc-route-table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my-vpc-gateway.id
}

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "my-vpc-association" {
  subnet_id = aws_subnet.my-vpc-subnet.id
  route_table_id = aws_route_table.my-vpc-route-table.id
}
