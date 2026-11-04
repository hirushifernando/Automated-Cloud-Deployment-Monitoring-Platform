
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
# Find the existing CloudOps EC2 instance
data "aws_instance" "cloudops" {
  instance_id = "i-0eba8e81414603f38"
}
# Find the existing CloudOps security group
data "aws_security_group" "cloudops" {
  id = "sg-09547a56cc9c8191e"
}
# Find the existing CloudOps EC2 IAM role
data "aws_iam_role" "cloudops" {
  name = "CloudOpsEC2Role"
}