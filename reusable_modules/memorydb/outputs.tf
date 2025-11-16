# Cluster Outputs
output "cluster_arn" {
  description = "ARN of the MemoryDB cluster"
  value       = aws_memorydb_cluster.this.arn
}

output "cluster_endpoint" {
  description = "DNS hostname of the cluster configuration endpoint"
  value       = aws_memorydb_cluster.this.cluster_endpoint
}

output "cluster_name" {
  description = "Name of the MemoryDB cluster"
  value       = aws_memorydb_cluster.this.name
}

output "cluster_id" {
  description = "ID of the MemoryDB cluster"
  value       = aws_memorydb_cluster.this.id
}

output "cluster_port" {
  description = "Port number on which the cluster accepts connections"
  value       = aws_memorydb_cluster.this.port
}

output "cluster_engine_version" {
  description = "Version number of the Redis engine"
  value       = aws_memorydb_cluster.this.engine_version
}

output "cluster_shards" {
  description = "Set of shards in the cluster"
  value       = aws_memorydb_cluster.this.shards
}

# Subnet Group Outputs
output "subnet_group_arn" {
  description = "ARN of the subnet group"
  value       = var.create_subnet_group ? aws_memorydb_subnet_group.this[0].arn : null
}

output "subnet_group_name" {
  description = "Name of the subnet group"
  value       = var.create_subnet_group ? aws_memorydb_subnet_group.this[0].name : null
}

# Parameter Group Outputs
output "parameter_group_arn" {
  description = "ARN of the parameter group"
  value       = var.create_parameter_group ? aws_memorydb_parameter_group.this[0].arn : null
}

output "parameter_group_name" {
  description = "Name of the parameter group"
  value       = var.create_parameter_group ? aws_memorydb_parameter_group.this[0].name : null
}

# ACL Outputs
output "acl_arn" {
  description = "ARN of the ACL"
  value       = var.create_acl ? aws_memorydb_acl.this[0].arn : null
}

output "acl_name" {
  description = "Name of the ACL"
  value       = var.create_acl ? aws_memorydb_acl.this[0].name : null
}

# User Outputs
output "user_arns" {
  description = "Map of user ARNs"
  value       = { for k, v in aws_memorydb_user.this : k => v.arn }
}

output "user_names" {
  description = "Map of user names"
  value       = { for k, v in aws_memorydb_user.this : k => v.user_name }
}

# Snapshot Outputs
output "snapshot_arn" {
  description = "ARN of the snapshot"
  value       = var.create_snapshot ? aws_memorydb_snapshot.this[0].arn : null
}

output "snapshot_name" {
  description = "Name of the snapshot"
  value       = var.create_snapshot ? aws_memorydb_snapshot.this[0].name : null
}