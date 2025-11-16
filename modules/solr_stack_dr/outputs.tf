# =============================================================================
# SOLR STACK DR MODULE OUTPUTS (Refactored with Reusable Modules)
# =============================================================================

# Subnet Outputs
output "solr_private_subnet_ids" {
  description = "List of Solr private subnet IDs"
  value       = values(module.solr_subnets.private_subnet_ids)
}

output "solr_public_subnet_ids" {
  description = "List of Solr public subnet IDs"
  value       = values(module.solr_subnets.public_subnet_ids)
}

# Security Group Outputs
output "solr_security_group_id" {
  description = "ID of the Solr cluster security group"
  value       = module.solr_security_group.security_group_id
}

# Load Balancer Outputs
output "solr_alb_arn" {
  description = "ARN of the Solr Application Load Balancer"
  value       = module.solr_alb.load_balancer_arn
}

output "solr_alb_dns_name" {
  description = "DNS name of the Solr Application Load Balancer"
  value       = module.solr_alb.load_balancer_dns_name
}

output "solr_target_group_arn" {
  description = "ARN of the Solr target group"
  value       = module.solr_alb.target_group_arns[0]
}

# IAM Outputs
output "solr_iam_role_arn" {
  description = "ARN of the Solr IAM role"
  value       = module.solr_iam.role_arn
}

output "solr_instance_profile_name" {
  description = "Name of the Solr instance profile"
  value       = module.solr_iam.instance_profile_name
}

# S3 Bucket Outputs
output "solr_backup_bucket_name" {
  description = "Name of the Solr backup S3 bucket"
  value       = module.solr_backup_bucket.bucket_name
}

output "solr_backup_bucket_arn" {
  description = "ARN of the Solr backup S3 bucket"
  value       = module.solr_backup_bucket.bucket_arn
}

# Auto Scaling Group Outputs
output "solr_autoscaling_group_name" {
  description = "Name of the Solr Auto Scaling Group"
  value       = module.solr_autoscaling.autoscaling_group_name
}

output "solr_launch_template_id" {
  description = "ID of the Solr launch template"
  value       = module.solr_autoscaling.launch_template_id
}

# EFS Outputs
output "solr_efs_id" {
  description = "ID of the Solr EFS file system"
  value       = aws_efs_file_system.solr_efs.id
}

output "solr_efs_dns_name" {
  description = "DNS name of the Solr EFS file system"
  value       = aws_efs_file_system.solr_efs.dns_name
}

output "solr_efs_mount_target_ids" {
  description = "List of EFS mount target IDs"
  value       = aws_efs_mount_target.solr_efs_mount[*].id
}
