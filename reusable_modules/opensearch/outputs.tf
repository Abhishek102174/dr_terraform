# Domain/Collection Outputs
output "domain_arn" {
  description = "ARN of the OpenSearch domain or collection"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].arn : aws_opensearchserverless_collection.this[0].arn
}

output "domain_id" {
  description = "Unique identifier for the OpenSearch domain or collection"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].domain_id : aws_opensearchserverless_collection.this[0].id
}

output "domain_name" {
  description = "Name of the OpenSearch domain or collection"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].domain_name : aws_opensearchserverless_collection.this[0].name
}

output "domain_endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].endpoint : aws_opensearchserverless_collection.this[0].collection_endpoint
}

output "dashboard_endpoint" {
  description = "Domain-specific endpoint for OpenSearch Dashboards"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].dashboard_endpoint : aws_opensearchserverless_collection.this[0].dashboard_endpoint
}

output "deployment_type" {
  description = "Deployment type (provisioned or serverless)"
  value       = var.deployment_type
}

# VPC Outputs
output "vpc_options" {
  description = "VPC options for the domain"
  value = var.deployment_type == "provisioned" && var.vpc_enabled ? {
    availability_zones = aws_opensearch_domain.this[0].vpc_options[0].availability_zones
    security_group_ids = aws_opensearch_domain.this[0].vpc_options[0].security_group_ids
    subnet_ids         = aws_opensearch_domain.this[0].vpc_options[0].subnet_ids
    vpc_id             = aws_opensearch_domain.this[0].vpc_options[0].vpc_id
  } : null
}

# CloudWatch Log Groups
output "index_slow_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for index slow logs (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.index_slow_logs_enabled ? aws_cloudwatch_log_group.index_slow_logs[0].arn : null
}

output "search_slow_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for search slow logs (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.search_slow_logs_enabled ? aws_cloudwatch_log_group.search_slow_logs[0].arn : null
}

output "es_application_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for ES application logs (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.es_application_logs_enabled ? aws_cloudwatch_log_group.es_application_logs[0].arn : null
}

output "audit_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for audit logs"
  value       = var.deployment_type == "provisioned" && var.audit_logs_enabled ? aws_cloudwatch_log_group.audit_logs[0].arn : (var.deployment_type == "serverless" && var.audit_logs_enabled ? aws_cloudwatch_log_group.serverless_audit_logs[0].arn : null)
}

output "error_logs_cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for error logs (serverless only)"
  value       = var.deployment_type == "serverless" && var.error_logs_enabled ? aws_cloudwatch_log_group.serverless_error_logs[0].arn : null
}

# Service Linked Role
output "service_linked_role_arn" {
  description = "ARN of the service linked role (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.create_service_linked_role ? aws_iam_service_linked_role.opensearch[0].arn : null
}

# Domain Configuration
output "engine_version" {
  description = "OpenSearch engine version (provisioned only)"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].engine_version : null
}

output "collection_type" {
  description = "Collection type (serverless only)"
  value       = var.deployment_type == "serverless" ? aws_opensearchserverless_collection.this[0].type : null
}

# Serverless Security Policy Outputs
output "encryption_policy_name" {
  description = "Name of the encryption security policy (serverless only)"
  value       = var.deployment_type == "serverless" && var.create_encryption_policy ? aws_opensearchserverless_security_policy.encryption[0].name : null
}

output "network_policy_name" {
  description = "Name of the network security policy (serverless only)"
  value       = var.deployment_type == "serverless" && var.create_network_policy ? aws_opensearchserverless_security_policy.network[0].name : null
}

output "data_access_policy_name" {
  description = "Name of the data access policy (serverless only)"
  value       = var.deployment_type == "serverless" && var.create_data_access_policy ? aws_opensearchserverless_access_policy.data[0].name : null
}

output "serverless_vpc_endpoint_id" {
  description = "ID of the serverless VPC endpoint"
  value       = var.deployment_type == "serverless" && var.create_vpc_endpoint ? aws_opensearchserverless_vpc_endpoint.serverless[0].id : null
}

output "cluster_config" {
  description = "Cluster configuration of the domain (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    instance_type            = aws_opensearch_domain.this[0].cluster_config[0].instance_type
    instance_count           = aws_opensearch_domain.this[0].cluster_config[0].instance_count
    dedicated_master_enabled = aws_opensearch_domain.this[0].cluster_config[0].dedicated_master_enabled
    zone_awareness_enabled   = aws_opensearch_domain.this[0].cluster_config[0].zone_awareness_enabled
    warm_enabled             = aws_opensearch_domain.this[0].cluster_config[0].warm_enabled
    warm_count               = aws_opensearch_domain.this[0].cluster_config[0].warm_count
    warm_type                = aws_opensearch_domain.this[0].cluster_config[0].warm_type
  } : null
}

output "ebs_options" {
  description = "EBS options of the domain (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    ebs_enabled = aws_opensearch_domain.this[0].ebs_options[0].ebs_enabled
    volume_type = aws_opensearch_domain.this[0].ebs_options[0].volume_type
    volume_size = aws_opensearch_domain.this[0].ebs_options[0].volume_size
    iops        = aws_opensearch_domain.this[0].ebs_options[0].iops
    throughput  = aws_opensearch_domain.this[0].ebs_options[0].throughput
  } : null
}

output "encrypt_at_rest" {
  description = "Encryption at rest configuration (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    enabled    = aws_opensearch_domain.this[0].encrypt_at_rest[0].enabled
    kms_key_id = aws_opensearch_domain.this[0].encrypt_at_rest[0].kms_key_id
  } : null
}

output "node_to_node_encryption" {
  description = "Node-to-node encryption configuration (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    enabled = aws_opensearch_domain.this[0].node_to_node_encryption[0].enabled
  } : null
}

output "domain_endpoint_options" {
  description = "Domain endpoint options (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    enforce_https       = aws_opensearch_domain.this[0].domain_endpoint_options[0].enforce_https
    tls_security_policy = aws_opensearch_domain.this[0].domain_endpoint_options[0].tls_security_policy
  } : null
}

output "advanced_security_options" {
  description = "Advanced security options (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    enabled                        = aws_opensearch_domain.this[0].advanced_security_options[0].enabled
    anonymous_auth_enabled         = aws_opensearch_domain.this[0].advanced_security_options[0].anonymous_auth_enabled
    internal_user_database_enabled = aws_opensearch_domain.this[0].advanced_security_options[0].internal_user_database_enabled
  } : null
}

output "snapshot_options" {
  description = "Snapshot options (provisioned only)"
  value = var.deployment_type == "provisioned" ? {
    automated_snapshot_start_hour = aws_opensearch_domain.this[0].snapshot_options[0].automated_snapshot_start_hour
  } : null
}

output "tags" {
  description = "Tags assigned to the domain or collection"
  value       = var.deployment_type == "provisioned" ? aws_opensearch_domain.this[0].tags : aws_opensearchserverless_collection.this[0].tags
}

# Policy Outputs
output "domain_policy_json" {
  description = "Generated domain policy JSON (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.create_access_policy_document ? data.aws_iam_policy_document.domain_policy[0].json : null
}

# VPC Endpoint Outputs
output "vpc_endpoint_id" {
  description = "ID of the VPC endpoint (provisioned only)"
  value       = var.deployment_type == "provisioned" && var.create_vpc_endpoint ? aws_opensearch_vpc_endpoint.this[0].id : null
}



# Package Association Outputs
output "package_associations" {
  description = "Package associations created"
  value = {
    for k, v in aws_opensearch_package_association.this : k => {
      package_id  = v.package_id
      domain_name = v.domain_name
    }
  }
}

# KMS Key Outputs
output "kms_key_arn" {
  description = "ARN of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.opensearch[0].arn : null
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = var.create_kms_key ? aws_kms_key.opensearch[0].key_id : null
}

output "kms_key_alias" {
  description = "Alias of the KMS key"
  value       = var.create_kms_key ? aws_kms_alias.opensearch[0].name : null
}

# Configuration Summary
output "configuration_summary" {
  description = "Summary of the OpenSearch configuration"
  value = {
    deployment_type = var.deployment_type
    name           = var.domain_name
    type           = var.deployment_type == "provisioned" ? "domain" : var.collection_type
    vpc_enabled    = var.vpc_enabled
    logging_enabled = var.audit_logs_enabled || (var.deployment_type == "provisioned" && (var.index_slow_logs_enabled || var.search_slow_logs_enabled || var.es_application_logs_enabled)) || (var.deployment_type == "serverless" && var.error_logs_enabled)
    kms_key_created = var.create_kms_key
    encryption_enabled = var.deployment_type == "provisioned" ? var.encrypt_at_rest : var.create_encryption_policy
  }
}