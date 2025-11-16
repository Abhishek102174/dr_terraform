# Private ECR Repository
resource "aws_ecr_repository" "private" {
  for_each = var.repository_type == "private" ? toset(var.repository_names) : []

  name                 = each.value
  image_tag_mutability = var.image_tag_mutability
  force_delete         = var.force_delete

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_type
    kms_key        = var.kms_key_id
  }

  tags = merge(var.tags, {
    Name = each.value
  })
}

# Public ECR Repository
resource "aws_ecrpublic_repository" "public" {
  for_each = var.repository_type == "public" ? toset(var.repository_names) : []

  repository_name = each.value
  force_destroy   = var.force_delete

  catalog_data {
    description      = var.public_repository_catalog_data.description != null ? var.public_repository_catalog_data.description : "Public ECR repository for ${each.value}"
    about_text       = var.public_repository_catalog_data.about_text
    usage_text       = var.public_repository_catalog_data.usage_text
    operating_systems = var.public_repository_catalog_data.operating_systems
    architectures    = var.public_repository_catalog_data.architectures
    logo_image_blob  = var.public_repository_catalog_data.logo_image_blob
  }

  tags = var.tags
}

# Repository Policy (Private only)
resource "aws_ecr_repository_policy" "private" {
  for_each = var.repository_policy != null && var.repository_type == "private" ? toset(var.repository_names) : []

  repository = aws_ecr_repository.private[each.value].name
  policy     = var.repository_policy
}

# Lifecycle Policy (Private only)
resource "aws_ecr_lifecycle_policy" "private" {
  for_each = var.lifecycle_policy != null && var.repository_type == "private" ? toset(var.repository_names) : []

  repository = aws_ecr_repository.private[each.value].name
  policy     = var.lifecycle_policy
}

# Registry Policy
resource "aws_ecr_registry_policy" "registry" {
  count = var.registry_policy != null ? 1 : 0

  policy = var.registry_policy
}

# Registry Scanning Configuration
resource "aws_ecr_registry_scanning_configuration" "registry" {
  count = var.registry_scan_type != null ? 1 : 0

  scan_type = var.registry_scan_type

  dynamic "rule" {
    for_each = var.registry_scan_rules
    content {
      scan_frequency = rule.value.scan_frequency
      repository_filter {
        filter      = rule.value.repository_filter.filter
        filter_type = rule.value.repository_filter.filter_type
      }
    }
  }
}

# Replication Configuration
resource "aws_ecr_replication_configuration" "replication" {
  count = length(var.replication_configuration) > 0 ? 1 : 0

  replication_configuration {
    dynamic "rule" {
      for_each = var.replication_configuration
      content {
        dynamic "destination" {
          for_each = rule.value.destinations
          content {
            region      = destination.value.region
            registry_id = destination.value.registry_id
          }
        }
        dynamic "repository_filter" {
          for_each = rule.value.repository_filters
          content {
            filter      = repository_filter.value.filter
            filter_type = repository_filter.value.filter_type
          }
        }
      }
    }
  }
}

# Pull Through Cache Rules
resource "aws_ecr_pull_through_cache_rule" "cache_rules" {
  for_each = var.pull_through_cache_rules

  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
  credential_arn       = each.value.credential_arn
}