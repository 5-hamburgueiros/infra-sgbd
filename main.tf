provider "aws" {
  region  = "us-east-1"
}

terraform {
  backend "s3" {
    bucket = "state-terraform-fiap-grupo-52"
    key    = "infra-sgbd"
    region = "us-east-1"
  }
}

resource "aws_default_vpc" "default_vpc" {}

resource "aws_security_group" "database_security_group" {
  name        = "database security group"
  description = "enable db access on port 5432"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    from_port        = 5432
    to_port          = 5432
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "db_instance" {
  identifier             = "postgres-instance"
  instance_class         = "db.t3.micro"
  allocated_storage      = 10
  engine                 = "postgres"
  engine_version         = "16.1"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.database_security_group.id]
  username               = var.db_username
  password               = var.db_password
}