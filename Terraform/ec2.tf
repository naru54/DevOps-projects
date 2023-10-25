terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

# Define your AWS provider settings
provider "aws" {
  region = "ap-southeast-1" 
}

# Create a VPC
resource "aws_vpc" "my_vpc_cicd" {
  cidr_block = "10.0.0.0/16" 
  enable_dns_support = true
  enable_dns_hostnames = true
   tags = {
    Name = "MY-VPC-cicd"
  }
}

# public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.my_vpc_cicd.id
  cidr_block = "10.0.1.0/24" 
  availability_zone = "ap-southeast-1a" 
  map_public_ip_on_launch = true
  tags = {
    Name = "jenkins-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc_cicd.id

  tags = {
    Name = "MY-IGW-CICD"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc_cicd.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt-jenkins"
  }
}

resource "aws_route_table_association" "public-rt-association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


#  security group for your Jenkins server
resource "aws_security_group" "jenkins_sg" {
  name  = "jenkins-sg"
  description = "jenkins security group"
  vpc_id = aws_vpc.my_vpc_cicd.id

  # You should allow SSH, HTTP, and HTTPS for Jenkins.

# Ingress rule for SSH (Port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTP (Port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for HTTPS (Port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress rule for jenkins (Port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "jenkins-sec-grp"
  }
}


#  Jenkins instance
resource "aws_instance" "jenkins" {
  ami           = "ami-01df4a8e4112a56a3" 
  instance_type = "t3.medium"    
  subnet_id     = aws_subnet.public_subnet.id
  security_groups = [aws_security_group.jenkins_sg.id]
  key_name = "CICD-linux"
  associate_public_ip_address = true
  user_data = "${file("jenkins_user_data.sh")}"

  tags = {
    Name = "jenkins"
  }
}

output "jenkins_ip" {
  value       = aws_instance.jenkins.private_ip
  description = "use this in docker daemon.json"
}








