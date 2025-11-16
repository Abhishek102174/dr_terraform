# File System Outputs
output "file_system_id" {
  description = "ID of the EFS file system"
  value       = aws_efs_file_system.this.id
}

output "file_system_arn" {
  description = "ARN of the EFS file system"
  value       = aws_efs_file_system.this.arn
}

output "file_system_dns_name" {
  description = "DNS name of the EFS file system"
  value       = aws_efs_file_system.this.dns_name
}

output "file_system_creation_token" {
  description = "Creation token of the EFS file system"
  value       = aws_efs_file_system.this.creation_token
}

output "file_system_performance_mode" {
  description = "Performance mode of the EFS file system"
  value       = aws_efs_file_system.this.performance_mode
}

output "file_system_throughput_mode" {
  description = "Throughput mode of the EFS file system"
  value       = aws_efs_file_system.this.throughput_mode
}

output "file_system_size_in_bytes" {
  description = "Size of the EFS file system in bytes"
  value       = aws_efs_file_system.this.size_in_bytes
}

# Mount Target Outputs
output "mount_target_ids" {
  description = "Map of subnet IDs to mount target IDs"
  value       = { for k, v in aws_efs_mount_target.this : k => v.id }
}

output "mount_target_dns_names" {
  description = "Map of subnet IDs to mount target DNS names"
  value       = { for k, v in aws_efs_mount_target.this : k => v.dns_name }
}

output "mount_target_ip_addresses" {
  description = "Map of subnet IDs to mount target IP addresses"
  value       = { for k, v in aws_efs_mount_target.this : k => v.ip_address }
}

# Access Point Outputs
output "access_point_ids" {
  description = "Map of access point names to IDs"
  value       = { for k, v in aws_efs_access_point.this : k => v.id }
}

output "access_point_arns" {
  description = "Map of access point names to ARNs"
  value       = { for k, v in aws_efs_access_point.this : k => v.arn }
}

# KMS Key Outputs
output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.efs[0].key_id : var.kms_key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.efs[0].arn : var.kms_key_id
}

output "kms_alias_name" {
  description = "Name of the KMS key alias"
  value       = var.create_kms_key ? aws_kms_alias.efs[0].name : null
}

# Replication Outputs
output "replication_configuration_id" {
  description = "ID of the replication configuration"
  value       = var.replication_configuration != null ? aws_efs_replication_configuration.this[0].id : null
}