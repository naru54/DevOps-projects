terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.22.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-southeast-1"
}

resource "aws_vpc" "rds_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "rds-VPC"
  }
}

resource "aws_subnet" "rds_sub1" {
  vpc_id     = aws_vpc.rds_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "rds-subnet1"
  }
}

resource "aws_subnet" "rds_sub2" {
  vpc_id     = aws_vpc.rds_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1b"

  tags = {
    Name = "rds-subnet2"
  }
}

  resource "aws_db_subnet_group" "sonar_db_subnet_group" {
  name       = "sonar-db-subnet-group"
  subnet_ids = [aws_subnet.rds_sub1.id, aws_subnet.rds_sub2.id]
}

resource "aws_security_group" "my_rds_sg" {
  name        = "my-rds-sg"
  description = "Security group for RDS instance"
  vpc_id      =  aws_vpc.rds_vpc.id

  # Ingress rule to allow incoming connections on the RDS port (e.g mysql port number: 3306 )
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.sonarqube_sg.id] 
  }
  
  tags = {
    Name = "rds-sec-grp"
  }
}


resource "aws_db_instance" "sonarqube_db" {

  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  db_name              = "sonardb"
  username             = "admin"
  password             = "admin123"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  availability_zone = "ap-southeast-1a"
  
  vpc_security_group_ids = [aws_security_group.my_rds_sg.id]
  db_subnet_group_name = aws_db_subnet_group.sonar_db_subnet_group.name 

  # Define the preferred backup window and maintenance window
  multi_az             = false  # Set to true if you want a Multi-AZ deployment
  publicly_accessible  = false  # Set to true if the RDS instance should be publicly accessible
  storage_encrypted    = true  # Set to true for storage encryption

}




