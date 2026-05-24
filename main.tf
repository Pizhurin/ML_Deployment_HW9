
terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "ml_bucket" {
  bucket = "ml-stock-pipeline-bucket"

  tags = {
    Name        = "ML Pipeline Bucket"
    Environment = "dev"
    Monitoring  = "enabled"
  }
}

resource "aws_instance" "airflow_server" {
  ami           = "ami-0faab6bdbac9486fb"
  instance_type = "t2.micro"

  tags = {
    Name        = "airflow-server"
    Monitoring  = "enabled"
  }
}

resource "aws_security_group" "airflow_sg" {
  name = "airflow-security-group"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "ml_logs" {
  name              = "/mlops/airflow"
  retention_in_days = 7
}

output "s3_bucket_name" {
  value = aws_s3_bucket.ml_bucket.bucket
}

output "airflow_instance_ip" {
  value = aws_instance.airflow_server.public_ip
}
