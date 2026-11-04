
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
  value       = data.aws_ecr_repository.cloudops.repository_url
}
