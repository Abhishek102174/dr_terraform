output "repository_arns" {
  description = "ARNs of the ECR repositories"
  value = merge(
    { for k, v in aws_ecr_repository.private : k => v.arn },
    { for k, v in aws_ecrpublic_repository.public : k => v.arn }
  )
}

output "repository_urls" {
  description = "URLs of the ECR repositories"
  value = merge(
    { for k, v in aws_ecr_repository.private : k => v.repository_url },
    { for k, v in aws_ecrpublic_repository.public : k => v.repository_uri }
  )
}

output "registry_ids" {
  description = "Registry IDs of the ECR repositories"
  value = merge(
    { for k, v in aws_ecr_repository.private : k => v.registry_id },
    { for k, v in aws_ecrpublic_repository.public : k => v.registry_id }
  )
}

output "repository_names" {
  description = "Names of the ECR repositories"
  value = merge(
    { for k, v in aws_ecr_repository.private : k => v.name },
    { for k, v in aws_ecrpublic_repository.public : k => v.repository_name }
  )
}

output "registry_policy_arn" {
  description = "ARN of the registry policy"
  value       = var.registry_policy != null ? aws_ecr_registry_policy.registry[0].registry_id : null
}

output "registry_scanning_configuration_registry_id" {
  description = "Registry ID for scanning configuration"
  value       = var.registry_scan_type != null ? aws_ecr_registry_scanning_configuration.registry[0].registry_id : null
}

output "replication_configuration_registry_id" {
  description = "Registry ID for replication configuration"
  value       = length(var.replication_configuration) > 0 ? aws_ecr_replication_configuration.replication[0].registry_id : null
}

output "pull_through_cache_rules" {
  description = "Pull through cache rules"
  value = {
    for k, v in aws_ecr_pull_through_cache_rule.cache_rules : k => {
      ecr_repository_prefix = v.ecr_repository_prefix
      upstream_registry_url = v.upstream_registry_url
      registry_id          = v.registry_id
    }
  }
}

# IAM Outputs
output "pull_role_arn" {
  description = "ARN of the ECR pull role"
  value       = var.create_pull_role ? aws_iam_role.ecr_pull_role[0].arn : null
}

output "pull_role_name" {
  description = "Name of the ECR pull role"
  value       = var.create_pull_role ? aws_iam_role.ecr_pull_role[0].name : null
}

output "push_role_arn" {
  description = "ARN of the ECR push role"
  value       = var.create_push_role ? aws_iam_role.ecr_push_role[0].arn : null
}

output "push_role_name" {
  description = "Name of the ECR push role"
  value       = var.create_push_role ? aws_iam_role.ecr_push_role[0].name : null
}