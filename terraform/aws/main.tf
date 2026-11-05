
# AWS account information
data "aws_caller_identity" "current" {}

# Find the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Find the existing CloudOps ECR repository
# Manage the existing CloudOps ECR repository
resource "aws_ecr_repository" "cloudops" {
  name                 = "cloudops-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  lifecycle {
    prevent_destroy = true
  }
}
# Find the existing CloudOps EC2 instance
data "aws_instance" "cloudops" {
  instance_id = "i-0eba8e81414603f38"
}
# Manage the existing CloudOps security group
resource "aws_security_group" "cloudops" {
  name        = "CloudOpsSecurityGroup"
  description = "Security group for CloudOps EC2 deployment"
  vpc_id      = "vpc-05b83c4c89de50ec3"

  ingress {
    description = "CloudOps FastAPI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["112.134.158.103/32"]
  }

   ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["112.134.158.103/32"]
  }

  ingress {
    description     = "EC2 Instance Connect"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = ["pl-0e1bc5673b8a57acc"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    Project = "CloudOps"
  }
}
# Find the existing CloudOps EC2 IAM role
data "aws_iam_role" "cloudops" {
  name = "CloudOpsEC2Role"
}