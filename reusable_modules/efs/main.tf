# EFS File System
resource "aws_efs_file_system" "this" {
  creation_token   = var.creation_token
  performance_mode = var.performance_mode
  throughput_mode  = var.throughput_mode
  
  provisioned_throughput_in_mibps = var.throughput_mode == "provisioned" ? var.provisioned_throughput_in_mibps : null
  
  encrypted  = var.encrypted
  kms_key_id = var.encrypted ? local.kms_key_id : null
  
  dynamic "lifecycle_policy" {
    for_each = var.lifecycle_policy != null ? [var.lifecycle_policy] : []
    content {
      transition_to_ia                    = lifecycle_policy.value.transition_to_ia
      transition_to_primary_storage_class = lifecycle_policy.value.transition_to_primary_storage_class
    }
  }

  tags = merge(var.tags, {
    Name = var.name
  })
}

# EFS Mount Targets
resource "aws_efs_mount_target" "this" {
  for_each = toset(var.subnet_ids)
  
  file_system_id  = aws_efs_file_system.this.id
  subnet_id       = each.value
  security_groups = var.security_group_ids
  ip_address      = lookup(var.mount_target_ip_addresses, each.value, null)
}

# EFS Access Points
resource "aws_efs_access_point" "this" {
  for_each = var.access_points
  
  file_system_id = aws_efs_file_system.this.id
  
  dynamic "posix_user" {
    for_each = each.value.posix_user != null ? [each.value.posix_user] : []
    content {
      gid            = posix_user.value.gid
      uid            = posix_user.value.uid
      secondary_gids = posix_user.value.secondary_gids
    }
  }
  
  dynamic "root_directory" {
    for_each = each.value.root_directory != null ? [each.value.root_directory] : []
    content {
      path = root_directory.value.path
      
      dynamic "creation_info" {
        for_each = root_directory.value.creation_info != null ? [root_directory.value.creation_info] : []
        content {
          owner_gid   = creation_info.value.owner_gid
          owner_uid   = creation_info.value.owner_uid
          permissions = creation_info.value.permissions
        }
      }
    }
  }
  
  tags = merge(var.tags, {
    Name = each.key
  })
}

# EFS File System Policy
resource "aws_efs_file_system_policy" "this" {
  count = var.file_system_policy != null ? 1 : 0
  
  file_system_id                     = aws_efs_file_system.this.id
  policy                            = var.file_system_policy
  bypass_policy_lockout_safety_check = var.bypass_policy_lockout_safety_check
}

# EFS Backup Policy
resource "aws_efs_backup_policy" "this" {
  count = var.enable_backup_policy ? 1 : 0
  
  file_system_id = aws_efs_file_system.this.id
  
  backup_policy {
    status = "ENABLED"
  }
}

# EFS Replication Configuration
resource "aws_efs_replication_configuration" "this" {
  count = var.replication_configuration != null ? 1 : 0
  
  source_file_system_id = aws_efs_file_system.this.id
  
  destination {
    region                 = var.replication_configuration.destination_region
    availability_zone_name = var.replication_configuration.availability_zone_name
    kms_key_id            = var.replication_configuration.kms_key_id
  }
}

# Data sources
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# KMS Key for EFS encryption (optional)
resource "aws_kms_key" "efs" {
  count = var.create_kms_key ? 1 : 0
  
  description             = "KMS key for EFS ${var.name}"
  deletion_window_in_days = var.kms_key_deletion_window
  enable_key_rotation     = var.enable_kms_key_rotation
  
  policy = var.kms_key_policy != null ? var.kms_key_policy : jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowEFSService"
        Effect = "Allow"
        Principal = {
          Service = "elasticfilesystem.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = merge(var.tags, {
    Name    = "${var.name}-key"
    Service = "efs"
  })
}

resource "aws_kms_alias" "efs" {
  count = var.create_kms_key ? 1 : 0
  
  name          = "alias/${var.name}-efs"
  target_key_id = aws_kms_key.efs[0].key_id
}

# Local for KMS key ID selection
locals {
  kms_key_id = var.create_kms_key ? aws_kms_key.efs[0].arn : var.kms_key_id
}