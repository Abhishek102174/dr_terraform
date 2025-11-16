# OpenSearch Domain (Provisioned)
resource "aws_opensearch_domain" "this" {
  count = var.deployment_type == "provisioned" ? 1 : 0
  domain_name    = var.domain_name
  engine_version = var.engine_version

  cluster_config {
    instance_type            = var.instance_type
    instance_count           = var.instance_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_enabled ? var.dedicated_master_type : null
    dedicated_master_count   = var.dedicated_master_enabled ? var.dedicated_master_count : null
    zone_awareness_enabled   = var.zone_awareness_enabled
    warm_enabled            = var.warm_enabled
    warm_count              = var.warm_count
    warm_type               = var.warm_type

    dynamic "zone_awareness_config" {
      for_each = var.zone_awareness_enabled ? [1] : []
      content {
        availability_zone_count = var.availability_zone_count
      }
    }

    cold_storage_options {
      enabled = var.cold_storage_enabled
    }
  }

  ebs_options {
    ebs_enabled = var.ebs_enabled
    volume_type = var.volume_type
    volume_size = var.volume_size
    iops        = var.iops
    throughput  = var.throughput
  }

  dynamic "vpc_options" {
    for_each = var.vpc_enabled ? [1] : []
    content {
      security_group_ids = coalesce(var.security_group_ids, var.security_group_id != null ? [var.security_group_id] : null)
      subnet_ids         = coalesce(var.subnet_ids, var.vpc_module_subnet_ids)
    }
  }

  encrypt_at_rest {
    enabled    = var.encrypt_at_rest
    kms_key_id = local.kms_key_id
  }

  node_to_node_encryption {
    enabled = var.node_to_node_encryption
  }

  domain_endpoint_options {
    enforce_https       = var.enforce_https
    tls_security_policy = var.tls_security_policy
  }

  advanced_security_options {
    enabled                        = var.advanced_security_enabled
    anonymous_auth_enabled         = var.anonymous_auth_enabled
    internal_user_database_enabled = var.internal_user_database_enabled

    dynamic "master_user_options" {
      for_each = var.advanced_security_enabled && var.internal_user_database_enabled ? [1] : []
      content {
        master_user_name     = var.master_user_name
        master_user_password = var.master_user_password
      }
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.index_slow_logs_enabled ? [1] : []
    content {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow_logs[0].arn
      log_type                 = "INDEX_SLOW_LOGS"
      enabled                  = true
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.search_slow_logs_enabled ? [1] : []
    content {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow_logs[0].arn
      log_type                 = "SEARCH_SLOW_LOGS"
      enabled                  = true
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.es_application_logs_enabled ? [1] : []
    content {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_application_logs[0].arn
      log_type                 = "ES_APPLICATION_LOGS"
      enabled                  = true
    }
  }

  dynamic "log_publishing_options" {
    for_each = var.audit_logs_enabled ? [1] : []
    content {
      cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit_logs[0].arn
      log_type                 = "AUDIT_LOGS"
      enabled                  = true
    }
  }

  snapshot_options {
    automated_snapshot_start_hour = var.automated_snapshot_start_hour
  }

  auto_tune_options {
    desired_state       = var.auto_tune_desired_state
    rollback_on_disable = var.auto_tune_rollback_on_disable

    dynamic "maintenance_schedule" {
      for_each = var.auto_tune_maintenance_schedule
      content {
        start_at = maintenance_schedule.value.start_at
        duration {
          value = maintenance_schedule.value.duration_value
          unit  = maintenance_schedule.value.duration_unit
        }
        cron_expression_for_recurrence = maintenance_schedule.value.cron_expression
      }
    }
  }

  dynamic "aiml_options" {
    for_each = var.aiml_options != null ? [var.aiml_options] : []
    content {
      dynamic "natural_language_query_generation_options" {
        for_each = aiml_options.value.natural_language_query_generation_options != null ? [aiml_options.value.natural_language_query_generation_options] : []
        content {
          desired_state = natural_language_query_generation_options.value.desired_state
        }
      }

      dynamic "s3_vectors_engine" {
        for_each = aiml_options.value.s3_vectors_engine != null ? [aiml_options.value.s3_vectors_engine] : []
        content {
          enabled = s3_vectors_engine.value.enabled
        }
      }
    }
  }

  advanced_options = var.advanced_options
  access_policies  = var.use_separate_policy_resource ? null : (var.create_access_policy_document ? data.aws_iam_policy_document.domain_policy[0].json : var.domain_policy)

  tags = merge(var.tags, {
    Name = var.domain_name
  })

}

# OpenSearch Serverless Collection
resource "aws_opensearchserverless_collection" "this" {
  count       = var.deployment_type == "serverless" ? 1 : 0
  name        = var.domain_name
  type        = var.collection_type
  description = var.description

  depends_on = [
    aws_opensearchserverless_security_policy.encryption
  ]

  tags = merge(var.tags, {
    Name = var.domain_name
  })
}

# Serverless Security Policies
resource "aws_opensearchserverless_security_policy" "encryption" {
  count       = var.deployment_type == "serverless" && var.create_encryption_policy ? 1 : 0
  name        = "${var.domain_name}-encryption-policy"
  type        = "encryption"
  description = "Encryption policy for ${var.domain_name}"
  
  policy = jsonencode({
    Rules = [
      {
        Resource = [
          "collection/${var.domain_name}"
        ]
        ResourceType = "collection"
      }
    ]
    AWSOwnedKey = var.use_aws_owned_key
  })
}

resource "aws_opensearchserverless_security_policy" "network" {
  count       = var.deployment_type == "serverless" && var.create_network_policy ? 1 : 0
  name        = "${var.domain_name}-network-policy"
  type        = "network"
  description = "Network policy for ${var.domain_name}"
  
  policy = var.allow_from_public ? jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.domain_name}"
          ]
          ResourceType = "collection"
        },
        {
          Resource = [
            "collection/${var.domain_name}"
          ]
          ResourceType = "dashboard"
        }
      ]
      AllowFromPublic = true
    }
  ]) : jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.domain_name}"
          ]
          ResourceType = "collection"
        },
        {
          Resource = [
            "collection/${var.domain_name}"
          ]
          ResourceType = "dashboard"
        }
      ]
      AllowFromPublic = false
      SourceVPCEs = length(var.vpc_endpoint_ids) > 0 ? var.vpc_endpoint_ids : [aws_opensearchserverless_vpc_endpoint.serverless[0].id]
    }
  ])
  

}

resource "aws_opensearchserverless_access_policy" "data" {
  count       = var.deployment_type == "serverless" && var.create_data_access_policy ? 1 : 0
  name        = "${var.domain_name}-data-access-policy"
  type        = "data"
  description = "Data access policy for ${var.domain_name}"
  
  policy = jsonencode([
    {
      Rules = [
        {
          Resource = [
            "collection/${var.domain_name}"
          ]
          Permission = [
            "aoss:CreateCollectionItems",
            "aoss:DeleteCollectionItems",
            "aoss:UpdateCollectionItems",
            "aoss:DescribeCollectionItems"
          ]
          ResourceType = "collection"
        },
        {
          Resource = [
            "index/${var.domain_name}/*"
          ]
          Permission = [
            "aoss:CreateIndex",
            "aoss:DeleteIndex",
            "aoss:UpdateIndex",
            "aoss:DescribeIndex",
            "aoss:ReadDocument",
            "aoss:WriteDocument"
          ]
          ResourceType = "index"
        }
      ]
      Principal = var.data_access_principals
    }
  ])
  
  depends_on = [
    aws_opensearchserverless_collection.this
  ]
}

resource "aws_opensearchserverless_vpc_endpoint" "serverless" {
  count      = var.deployment_type == "serverless" && var.create_vpc_endpoint ? 1 : 0
  name       = "${var.domain_name}-vpc-endpoint"
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids
  
  security_group_ids = var.security_group_ids
}

# Service Linked Role for OpenSearch
resource "aws_iam_service_linked_role" "opensearch" {
  count            = var.deployment_type == "provisioned" && var.create_service_linked_role ? 1 : 0
  aws_service_name = "opensearchservice.amazonaws.com"
  description      = "Service linked role for OpenSearch"
}

# CloudWatch Log Groups (Provisioned)
resource "aws_cloudwatch_log_group" "index_slow_logs" {
  count             = var.deployment_type == "provisioned" && var.index_slow_logs_enabled ? 1 : 0
  name              = "/aws/opensearch/domains/${var.domain_name}/index-slow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "search_slow_logs" {
  count             = var.deployment_type == "provisioned" && var.search_slow_logs_enabled ? 1 : 0
  name              = "/aws/opensearch/domains/${var.domain_name}/search-slow-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "es_application_logs" {
  count             = var.deployment_type == "provisioned" && var.es_application_logs_enabled ? 1 : 0
  name              = "/aws/opensearch/domains/${var.domain_name}/es-application-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "audit_logs" {
  count             = var.deployment_type == "provisioned" && var.audit_logs_enabled ? 1 : 0
  name              = "/aws/opensearch/domains/${var.domain_name}/audit-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

# CloudWatch Log Groups (Serverless)
resource "aws_cloudwatch_log_group" "serverless_audit_logs" {
  count             = var.deployment_type == "serverless" && var.audit_logs_enabled ? 1 : 0
  name              = "/aws/opensearchserverless/collections/${var.domain_name}/audit-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "serverless_error_logs" {
  count             = var.deployment_type == "serverless" && var.error_logs_enabled ? 1 : 0
  name              = "/aws/opensearchserverless/collections/${var.domain_name}/error-logs"
  retention_in_days = var.log_retention_days
  kms_key_id        = local.log_kms_key_id

  tags = var.tags
}

# CloudWatch Log Resource Policy (Provisioned)
resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  count           = var.deployment_type == "provisioned" && var.create_log_resource_policy ? 1 : 0
  policy_name     = "${var.domain_name}-opensearch-log-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*"
      }
    ]
  })
  
  depends_on = [
    aws_cloudwatch_log_group.index_slow_logs,
    aws_cloudwatch_log_group.search_slow_logs,
    aws_cloudwatch_log_group.es_application_logs,
    aws_cloudwatch_log_group.audit_logs
  ]
}

# CloudWatch Log Resource Policy (Serverless)
resource "aws_cloudwatch_log_resource_policy" "opensearch_serverless" {
  count           = var.deployment_type == "serverless" && var.create_log_resource_policy ? 1 : 0
  policy_name     = "${var.domain_name}-serverless-log-policy"
  policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "es.amazonaws.com"
        }
        Action = [
          "logs:PutLogEvents",
          "logs:CreateLogGroup",
          "logs:CreateLogStream"
        ]
        Resource = "arn:aws:logs:*"
      }
    ]
  })
  
  depends_on = [
    aws_cloudwatch_log_group.serverless_audit_logs,
    aws_cloudwatch_log_group.serverless_error_logs
  ]
}

# Data sources for ARN construction
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# KMS Key for OpenSearch encryption (optional)
resource "aws_kms_key" "opensearch" {
  count                   = var.create_kms_key ? 1 : 0
  description             = var.deployment_type == "provisioned" ? "KMS key for OpenSearch domain ${var.domain_name}" : "KMS key for OpenSearch Serverless collection ${var.domain_name}"
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
        Sid    = "AllowOpenSearchService"
        Effect = "Allow"
        Principal = {
          Service = var.deployment_type == "provisioned" ? "opensearch.amazonaws.com" : "opensearchserverless.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.id}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = merge(var.tags, {
    Name        = "${var.domain_name}-${var.deployment_type}-key"
    Service     = var.deployment_type == "provisioned" ? "opensearch" : "opensearch-serverless"
    Domain      = var.domain_name
  })
}

resource "aws_kms_alias" "opensearch" {
  count         = var.create_kms_key ? 1 : 0
  name          = "alias/${var.domain_name}-${var.deployment_type}"
  target_key_id = aws_kms_key.opensearch[0].key_id
}

# Local for KMS key ID selection
locals {
  kms_key_id = var.create_kms_key ? aws_kms_key.opensearch[0].arn : var.kms_key_id
  log_kms_key_id = var.create_kms_key ? aws_kms_key.opensearch[0].arn : var.log_kms_key_id
}

# IAM Policy Document for Domain Access
data "aws_iam_policy_document" "domain_policy" {
  count = var.create_access_policy_document ? 1 : 0

  source_policy_documents   = var.access_policy_source_policy_documents
  override_policy_documents = var.access_policy_override_policy_documents

  dynamic "statement" {
    for_each = var.access_policy_statements

    content {
      sid         = try(statement.value.sid, null)
      actions     = try(statement.value.actions, null)
      not_actions = try(statement.value.not_actions, null)
      effect      = try(statement.value.effect, null)
      resources = try(statement.value.resources,
        [for path in try(statement.value.resource_paths, ["*"]) : "arn:aws:es:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/${path}"]
      )
      not_resources = try(statement.value.not_resources, null)

      dynamic "principals" {
        for_each = try(statement.value.principals, [])

        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "not_principals" {
        for_each = try(statement.value.not_principals, [])

        content {
          type        = not_principals.value.type
          identifiers = not_principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])

        content {
          test     = condition.value.test
          values   = condition.value.values
          variable = condition.value.variable
        }
      }
    }
  }
}

# Domain Policy (Alternative to access_policies in domain resource)
resource "aws_opensearch_domain_policy" "this" {
  count           = var.deployment_type == "provisioned" && var.use_separate_policy_resource ? 1 : 0
  domain_name     = aws_opensearch_domain.this[0].domain_name
  access_policies = var.create_access_policy_document ? data.aws_iam_policy_document.domain_policy[0].json : var.domain_policy
}

# VPC Endpoint for Private Access (Provisioned)
resource "aws_opensearch_vpc_endpoint" "this" {
  count       = var.deployment_type == "provisioned" && var.create_vpc_endpoint ? 1 : 0
  domain_arn  = aws_opensearch_domain.this[0].arn
  vpc_options {
    security_group_ids = var.vpc_endpoint_security_group_ids
    subnet_ids         = var.vpc_endpoint_subnet_ids
  }
}

# Package Associations for Custom Packages (Provisioned only)
resource "aws_opensearch_package_association" "this" {
  for_each    = var.deployment_type == "provisioned" ? var.packages : {}
  package_id  = each.value.package_id
  domain_name = aws_opensearch_domain.this[0].domain_name
}

# SAML Options (Provisioned only)
resource "aws_opensearch_domain_saml_options" "this" {
  count       = var.deployment_type == "provisioned" && var.saml_enabled ? 1 : 0
  domain_name = aws_opensearch_domain.this[0].domain_name

  saml_options {
    enabled = true
    idp {
      entity_id        = var.saml_entity_id
      metadata_content = var.saml_metadata_content
    }
    master_backend_role = var.saml_master_backend_role
    master_user_name    = var.saml_master_user_name
    roles_key           = var.saml_roles_key
    session_timeout_minutes = var.saml_session_timeout_minutes
    subject_key         = var.saml_subject_key
  }
}