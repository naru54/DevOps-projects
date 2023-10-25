terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.17.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}

resource "aws_security_group" "mysg" {
  name        = "mysg"
  description = "All-tcp"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "all tcp"
    from_port        = 0
    to_port          = 65535
    protocol         = "tcp"
     cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "all-tcp"
  }
}

