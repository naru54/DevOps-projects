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

resource "aws_s3_bucket" "mybucket" {
  bucket = "naru-tf-test-bucket"

  tags = {
    Name  = "naru-bucket"
    #Environment = "Dev"
  }
}

resource "aws_s3_object" "mys3object" {
  bucket = aws_s3_bucket.mybucket.id
  
  key = "index.html"
  content_type = "text/html"
  source = "/root/index.html"
  etag = "${md5(file("/root/index.html"))}"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.mybucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

