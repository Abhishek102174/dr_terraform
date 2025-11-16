# Provider Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Network Configuration
variable "vpc_id" {
  description = "VPC ID for OpenSearch deployment"
  type        = string
  default     = "vpc-12345678"
}

variable "subnet_ids" {
  description = "List of subnet IDs for OpenSearch deployment"
  type        = list(string)
  default     = ["subnet-12345678", "subnet-87654321"]
}

variable "security_group_ids" {
  description = "List of security group IDs for OpenSearch"
  type        = list(string)
  default     = ["sg-12345678"]
}

# General Configuration
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "opensearch-example"
}

# Advanced Security Configuration
variable "master_user_name" {
  description = "Master user name for OpenSearch domain"
  type        = string
  default     = "admin"
  sensitive   = true
}

variable "master_user_password" {
  description = "Master user password for OpenSearch domain"
  type        = string
  default     = "TempPassword123!"
  sensitive   = true
}

# KMS Configuration
variable "create_custom_kms_key" {
  description = "Whether to create a custom KMS key"
  type        = bool
  default     = false
}