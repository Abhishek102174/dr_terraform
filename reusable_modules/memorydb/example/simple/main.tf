# Random suffix for unique cluster names
resource "random_id" "suffix" {
  byte_length = 4
}

# Example: MemoryDB cluster with custom configuration
module "memorydb_cluster" {
  source = "../../"

  cluster_name        = "${var.project_name}-cluster-${random_id.suffix.hex}"
  cluster_description = "Example MemoryDB cluster for testing"
  
  # Network Configuration (user must provide existing subnet IDs and security group IDs)
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids

  # Cluster Configuration
  node_type                = var.node_type
  num_shards               = var.num_shards
  num_replicas_per_shard   = var.num_replicas_per_shard
  engine_version           = var.engine_version
  port                     = var.port
  tls_enabled              = var.tls_enabled
  auto_minor_version_upgrade = var.auto_minor_version_upgrade

  # Maintenance and Backup
  maintenance_window       = var.maintenance_window
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window

  # Subnet Group
  create_subnet_group = var.create_subnet_group
  subnet_group_name   = var.subnet_group_name

  # Parameter Group
  create_parameter_group      = var.create_parameter_group
  parameter_group_name        = var.parameter_group_name
  parameter_group_family      = var.parameter_group_family
  parameter_group_description = var.parameter_group_description
  
  parameters = var.parameters

  # ACL and Users
  create_acl = var.create_acl
  acl_name   = var.acl_name
  
  users = var.users

  # Snapshot
  create_snapshot = var.create_snapshot
  snapshot_name   = var.snapshot_name

  tags = merge(var.tags, {
    Name = "${var.project_name}-cluster"
  })
}