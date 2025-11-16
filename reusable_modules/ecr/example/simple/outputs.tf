output "private_repository_urls" {
  description = "URLs of the private ECR repositories"
  value       = module.ecr_private.repository_urls
}

output "private_repository_arns" {
  description = "ARNs of the private ECR repositories"
  value       = module.ecr_private.repository_arns
}

output "public_repository_urls" {
  description = "URLs of the public ECR repositories"
  value       = var.enable_public_repository ? module.ecr_public[0].repository_urls : {}
}

output "pull_role_arn" {
  description = "ARN of the ECR pull role"
  value       = module.ecr_private.pull_role_arn
}

output "push_role_arn" {
  description = "ARN of the ECR push role"
  value       = module.ecr_private.push_role_arn
}