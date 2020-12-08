provider "aws" {
  version = "~> 2.0"
  region = "ap-east-1"
  profile = "default"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "copy key.pub content here"
}

resource "aws_iam_instance_profile" "beanstalk_service" {
  name = "beanstalk-service-user"
  role = aws_iam_role.beanstalk_service.name
}

resource "aws_iam_instance_profile" "beanstalk_ec2" {
  name = "beanstalk-ec2-user"
  role = aws_iam_role.beanstalk_ec2.name
}

resource "aws_iam_role" "beanstalk_service" {
  name = "beanstalk-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "elasticbeanstalk"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role" "beanstalk_ec2" {
  name = "beanstalk-ec2-role"
  assume_role_policy = <<EOF
{
  "Version": "2008-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "beanstalk_service" {
  name = "elastic-beanstalk-service"
  roles = [aws_iam_role.beanstalk_service.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkService"
}

resource "aws_iam_policy_attachment" "beanstalk_service_health" {
  name = "elastic-beanstalk-service-health"
  roles = [aws_iam_role.beanstalk_service.id]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_worker" {
  name = "elastic-beanstalk-ec2-worker"
  roles = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWorkerTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_web" {
  name = "elastic-beanstalk-ec2-web"
  roles = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_policy_attachment" "beanstalk_ec2_container" {
  name = "elastic-beanstalk-ec2-container"
  roles = [aws_iam_role.beanstalk_ec2.id]
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkMulticontainerDocker"
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

# Create the Security Group
resource "aws_security_group" "my-vpc-security-group" {
  vpc_id = aws_vpc.my-vpc.id
  name = "My VPC Security Group"
  description = "My VPC Security Group"

  # allow ingress of port 443
  ingress {
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
    Name = "My VPC Security Group"
    Description = "My VPC Security Group"
  }
}

resource "aws_elastic_beanstalk_application" "application" {
  name = "my-eb-ap"
}

resource "aws_elastic_beanstalk_environment" "environment" {
  name = "my-eb-environment"
  application = aws_elastic_beanstalk_application.application.name
  solution_stack_name = "64bit Amazon Linux 2 v3.1.3 running Corretto 11"
  wait_for_ready_timeout = "20m"

  # Networking
  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.my-vpc.id
    resource  = ""
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "ELBScheme"
    value     = "internal"
    resource  = ""
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = join(",", sort(aws_subnet.my-vpc-subnet.*.id))
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "SecurityGroups"
    value     = aws_security_group.my-vpc-security-group.id
    resource  = ""
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "InstanceType"
    value = "t3.nano"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName"
    value     = aws_key_pair.deployer.key_name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name = "ServiceRole"
    value = aws_iam_instance_profile.beanstalk_service.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name = "IamInstanceProfile"
    value = aws_iam_instance_profile.beanstalk_ec2.name
  }

}