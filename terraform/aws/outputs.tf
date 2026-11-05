output "aws_account_id" {
  description = "AWS account ID"
  value       = data.aws_caller_identity.current.account_id
}

output "default_vpc_id" {
  description = "Existing default VPC ID"
  value       = data.aws_vpc.default.id
}

output "ecr_repository_url" {
  description = "Existing CloudOps ECR repository URL"
  value       = aws_ecr_repository.cloudops.repository_url
}

output "ec2_instance_id" {
  description = "Existing CloudOps EC2 instance ID"
  value       = data.aws_instance.cloudops.id
}

output "ec2_public_ip" {
  description = "Existing CloudOps EC2 public IP"
  value       = data.aws_instance.cloudops.public_ip
}

output "security_group_id" {
  description = "Existing CloudOps security group ID"
  value       = data.aws_security_group.cloudops.id
}

output "security_group_name" {
  description = "Existing CloudOps security group name"
  value       = data.aws_security_group.cloudops.name
}

output "iam_role_name" {
  description = "Existing CloudOps EC2 IAM role name"
  value       = data.aws_iam_role.cloudops.name
}

output "iam_role_arn" {
  description = "Existing CloudOps EC2 IAM role ARN"
  value       = data.aws_iam_role.cloudops.arn
}