# =============================================================================
# MULTI-ENVIRONMENT TERRAFORM OUTPUTS
# =============================================================================

# Environment Information
output "environment" {
  description = "Current environment being deployed"
  value       = local.environment
}

output "environment_config" {
  description = "Current environment configuration summary"
  value = {
    environment = local.environment
    vpc_name    = local.current_env.vpc_name
    vpc_cidr    = local.current_env.vpc_cidr
    region      = local.current_env.region
    tier        = local.current_env.common_tags.tier
  }
}

# VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.cidr_block
}

# Networking Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.networking.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = module.networking.nat_gateway_ids
}

output "transit_gateway_id" {
  description = "ID of the Transit Gateway (if enabled)"
  value       = module.networking.transit_gateway_id
}

# Solr Stack Outputs
output "solr_cluster_info" {
  description = "Solr cluster information"
  value = {
    name_prefix        = local.current_env.solr_name_prefix
    instance_type      = local.current_env.solr_instance_type
    cluster_size       = local.current_env.solr_cluster_size
    data_volume_size   = local.current_env.solr_data_volume_size
    alb_dns_name      = module.solr_stack.solr_alb_dns_name
    backup_bucket     = module.solr_stack.solr_backup_bucket_name
  }
}

output "solr_private_subnet_ids" {
  description = "List of Solr private subnet IDs"
  value       = module.solr_stack.solr_private_subnet_ids
}

output "solr_public_subnet_ids" {
  description = "List of Solr public subnet IDs"
  value       = module.solr_stack.solr_public_subnet_ids
}

output "solr_alb_dns_name" {
  description = "DNS name of the Solr Application Load Balancer"
  value       = module.solr_stack.solr_alb_dns_name
}

output "solr_backup_bucket_name" {
  description = "Name of the Solr backup S3 bucket"
  value       = module.solr_stack.solr_backup_bucket_name
}

# Security Outputs
output "solr_security_group_id" {
  description = "ID of the Solr cluster security group"
  value       = module.solr_stack.solr_security_group_id
}

# Auto Scaling Outputs
output "solr_autoscaling_group_name" {
  description = "Name of the Solr Auto Scaling Group"
  value       = module.solr_stack.solr_autoscaling_group_name
}
