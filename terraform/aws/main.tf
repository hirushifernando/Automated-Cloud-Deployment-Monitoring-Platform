
# AWS account information
data "aws_caller_identity" "current" {}

# Find the existing default VPC
data "aws_vpc" "default" {
  default = true
}

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

# Manage the existing CloudOps EC2 instance
resource "aws_instance" "cloudops" {
  ami                  = "ami-062900c135ab91582"
  instance_type        = "t3.micro"
  subnet_id             = "subnet-024cee613b9f4bc73"
  vpc_security_group_ids = [aws_security_group.cloudops.id]
  key_name              = "CloudOps-EC2-Key"
  iam_instance_profile  = "CloudOpsEC2Role"

  monitoring    = false
  ebs_optimized = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
    http_protocol_ipv6          = "disabled"
    instance_metadata_tags      = "disabled"
  }

  root_block_device {
    volume_size           = 8
    volume_type           = "gp3"
    encrypted             = true
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  tags = {
    Name = "CloudOps-EC2"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Manage the existing CloudOps security group
resource "aws_security_group" "cloudops" {
  name        = "CloudOpsSecurityGroup"
  description = "Security group for CloudOps EC2 deployment"
  vpc_id      = "vpc-05b83c4c89de50ec3"

  # FastAPI access
  ingress {
    description = "CloudOps FastAPI access"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["112.134.158.103/32"]
  }

  # SSH administration
  ingress {
    description = "SSH administration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["112.134.158.103/32"]
  }

  # AWS EC2 Instance Connect
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    prefix_list_ids = ["pl-0e1bc5673b8a57acc"]
  }

  # Allow outbound traffic
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
