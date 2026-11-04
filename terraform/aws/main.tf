
# AWS account information
data "aws_caller_identity" "current" {}

# Find the existing default VPC
data "aws_vpc" "default" {
  default = true
}

# Find the existing CloudOps ECR repository
data "aws_ecr_repository" "cloudops" {
  name = "cloudops-api"
}
