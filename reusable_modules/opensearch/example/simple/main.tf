# OpenSearch Serverless Collection with VPC
module "opensearch_serverless" {
  source = "../../"

  # Serverless deployment
  deployment_type = "serverless"
  domain_name     = "it-web-${var.environment}-opensearch-serverless"
  collection_type = "SEARCH"
  description     = "Example serverless collection with VPC access"
  
  # Security policies
  create_encryption_policy   = true
  use_aws_owned_key         = true
  create_network_policy     = true
  allow_from_public         = false
  create_data_access_policy = true
  
  # VPC configuration
  vpc_enabled        = true
  create_vpc_endpoint = true
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  
  # Data access principals
  data_access_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
  
  # Logging
  audit_logs_enabled         = true
  error_logs_enabled         = true
  create_log_resource_policy = true
  log_retention_days         = 14
  
  # KMS - using AWS-owned keys
  create_kms_key = false
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
    Type        = "serverless"
  }
}

# OpenSearch Domain (Provisioned) with basic configuration
module "opensearch_domain" {
  source = "../../"

  # Provisioned deployment
  deployment_type = "provisioned"
  domain_name     = "it-web-${var.environment}-opensearch"
  engine_version  = "OpenSearch_2.3"
  
  # Cluster configuration
  instance_type  = "t3.small.search"
  instance_count = 1
  
  # Storage
  volume_type = "gp3"
  volume_size = 20
  
  # Network - VPC deployment
  vpc_enabled        = true
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  
  # Security
  encrypt_at_rest          = true
  node_to_node_encryption = true
  enforce_https           = true
  
  # Logging
  audit_logs_enabled         = true
  create_log_resource_policy = true
  log_retention_days         = 7
  
  # KMS - using AWS-owned keys
  create_kms_key = false
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
    Type        = "provisioned"
  }
}

# Production OpenSearch Domain with advanced features
module "opensearch_production" {
  source = "../../"

  deployment_type = "provisioned"
  domain_name     = "it-web-${var.environment}-opensearch-prod"
  engine_version  = "OpenSearch_2.3"
  
  # Multi-AZ cluster
  instance_type            = "m6g.large.search"
  instance_count           = 3
  dedicated_master_enabled = true
  zone_awareness_enabled   = true
  availability_zone_count  = 3
  
  # Storage
  volume_type = "gp3"
  volume_size = 100
  
  # Network
  vpc_enabled        = true
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  
  # Security
  encrypt_at_rest                    = true
  node_to_node_encryption           = true
  enforce_https                      = true
  advanced_security_enabled          = true
  internal_user_database_enabled     = true
  master_user_name                   = var.master_user_name
  master_user_password               = var.master_user_password
  
  # Comprehensive logging
  index_slow_logs_enabled     = true
  search_slow_logs_enabled    = true
  es_application_logs_enabled = true
  audit_logs_enabled          = true
  create_log_resource_policy  = true
  log_retention_days          = 30
  
  # Auto-Tune
  auto_tune_desired_state = "ENABLED"
  
  # KMS
  create_kms_key = var.create_custom_kms_key
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Terraform   = "true"
    Type        = "production"
  }
}

data "aws_caller_identity" "current" {}