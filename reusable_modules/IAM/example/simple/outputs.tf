output "users" {
  description = "Information about created users"
  value       = module.iam.users
}

output "groups" {
  description = "Information about created groups"
  value       = module.iam.groups
}

output "roles" {
  description = "Information about created roles"
  value       = module.iam.roles
}

output "managed_policies" {
  description = "Information about created managed policies"
  value       = module.iam.managed_policies
}

output "oidc_providers" {
  description = "Information about created OIDC providers"
  value       = module.iam.oidc_providers
}

# Practical outputs for other modules
output "ec2_instance_role_arn" {
  description = "ARN of the EC2 instance role"
  value       = module.iam.roles["ec2-instance-role"].arn
}

output "github_actions_role_arn" {
  description = "ARN of the GitHub Actions role"
  value       = module.iam.roles["github-actions-role"].arn
}
