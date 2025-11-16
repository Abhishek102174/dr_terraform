# Serverless Collection Outputs
output "serverless_collection_arn" {
  description = "ARN of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.serverless_collection_arn
}

output "serverless_collection_endpoint" {
  description = "Endpoint of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.serverless_collection_endpoint
}

output "serverless_dashboard_endpoint" {
  description = "Dashboard endpoint of the OpenSearch Serverless collection"
  value       = module.opensearch_serverless.serverless_dashboard_endpoint
}

# Domain Outputs
output "domain_arn" {
  description = "ARN of the OpenSearch domain"
  value       = module.opensearch_domain.domain_arn
}

output "domain_endpoint" {
  description = "Endpoint of the OpenSearch domain"
  value       = module.opensearch_domain.domain_endpoint
}

output "dashboard_endpoint" {
  description = "Dashboard endpoint of the OpenSearch domain"
  value       = module.opensearch_domain.dashboard_endpoint
}

# Production Domain Outputs
output "production_domain_arn" {
  description = "ARN of the production OpenSearch domain"
  value       = module.opensearch_production.domain_arn
}

output "production_domain_endpoint" {
  description = "Endpoint of the production OpenSearch domain"
  value       = module.opensearch_production.domain_endpoint
}

# VPC Endpoint Outputs
output "serverless_vpc_endpoint_id" {
  description = "ID of the OpenSearch Serverless VPC endpoint"
  value       = module.opensearch_serverless.vpc_endpoint_id
}

# Log Group Outputs
output "serverless_log_groups" {
  description = "CloudWatch log groups for serverless collection"
  value = {
    audit_logs = module.opensearch_serverless.serverless_audit_log_group_name
    error_logs = module.opensearch_serverless.serverless_error_log_group_name
  }
}

output "domain_log_groups" {
  description = "CloudWatch log groups for OpenSearch domain"
  value = {
    audit_logs = module.opensearch_domain.audit_log_group_name
  }
}