output "memorydb_cluster_arn" {
  description = "ARN of the MemoryDB cluster"
  value       = module.memorydb_cluster.cluster_arn
}

output "memorydb_cluster_endpoint" {
  description = "Cluster endpoint for MemoryDB"
  value       = module.memorydb_cluster.cluster_endpoint
}

output "memorydb_cluster_port" {
  description = "Port of the MemoryDB cluster"
  value       = module.memorydb_cluster.port
}

output "memorydb_subnet_group_name" {
  description = "Name of the MemoryDB subnet group"
  value       = module.memorydb_cluster.subnet_group_name
}

output "memorydb_parameter_group_name" {
  description = "Name of the MemoryDB parameter group"
  value       = module.memorydb_cluster.parameter_group_name
}

output "memorydb_acl_name" {
  description = "Name of the MemoryDB ACL"
  value       = module.memorydb_cluster.acl_name
}

output "memorydb_user_names" {
  description = "Names of the MemoryDB users"
  value       = module.memorydb_cluster.user_names
}