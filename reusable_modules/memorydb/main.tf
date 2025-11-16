# MemoryDB Subnet Group (Required for MemoryDB)
resource "aws_memorydb_subnet_group" "this" {
  count = var.create_subnet_group ? 1 : 0

  name       = coalesce(var.subnet_group_name, "${var.cluster_name}-subnet-group")
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, {
    Name = coalesce(var.subnet_group_name, "${var.cluster_name}-subnet-group")
  })
}

# MemoryDB Parameter Group
resource "aws_memorydb_parameter_group" "this" {
  count = var.create_parameter_group ? 1 : 0

  name        = coalesce(var.parameter_group_name, "${var.cluster_name}-params")
  family      = var.parameter_group_family
  description = var.parameter_group_description

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(var.tags, {
    Name = coalesce(var.parameter_group_name, "${var.cluster_name}-params")
  })
}

# MemoryDB ACL
resource "aws_memorydb_acl" "this" {
  count = var.create_acl ? 1 : 0

  name       = var.create_acl && var.acl_name == "open-access" ? "${var.cluster_name}-acl" : var.acl_name
  user_names = length(var.users) > 0 ? keys(var.users) : var.acl_user_names

  depends_on = [aws_memorydb_user.this]

  tags = merge(var.tags, {
    Name = var.create_acl && var.acl_name == "open-access" ? "${var.cluster_name}-acl" : var.acl_name
  })
}

# MemoryDB Users
resource "aws_memorydb_user" "this" {
  for_each = var.users

  user_name     = each.key
  access_string = each.value.access_string

  authentication_mode {
    type      = each.value.authentication_mode.type
    passwords = each.value.authentication_mode.passwords
  }

  tags = merge(var.tags, {
    Name = each.key
  })
}

# MemoryDB Cluster
resource "aws_memorydb_cluster" "this" {
  name        = var.cluster_name
  description = var.cluster_description

  acl_name                 = var.create_acl ? aws_memorydb_acl.this[0].name : var.acl_name
  node_type                = var.node_type
  num_shards               = var.num_shards
  num_replicas_per_shard   = var.num_replicas_per_shard
  parameter_group_name     = var.create_parameter_group ? aws_memorydb_parameter_group.this[0].name : var.parameter_group_name
  port                     = var.port
  security_group_ids       = var.security_group_ids
  snapshot_retention_limit = var.snapshot_retention_limit
  snapshot_window          = var.snapshot_window
  sns_topic_arn           = var.sns_topic_arn
  subnet_group_name       = var.create_subnet_group ? aws_memorydb_subnet_group.this[0].name : var.subnet_group_name
  kms_key_arn             = var.kms_key_arn

  tls_enabled             = var.tls_enabled
  engine_version          = var.engine_version
  maintenance_window      = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  data_tiering            = var.data_tiering

  tags = merge(var.tags, {
    Name = var.cluster_name
  })
}

# MemoryDB Snapshot
resource "aws_memorydb_snapshot" "this" {
  count = var.create_snapshot ? 1 : 0

  cluster_name = aws_memorydb_cluster.this.name
  name         = coalesce(var.snapshot_name, "${var.cluster_name}-snapshot")

  tags = merge(var.tags, {
    Name = coalesce(var.snapshot_name, "${var.cluster_name}-snapshot")
  })
}