# =============================================================================
# MULTI-ENVIRONMENT TERRAFORM VARIABLES
# =============================================================================

# Environment Selection
variable "environment" {
  description = "Environment to deploy (dr, stage, prod). If empty, uses terraform workspace"
  type        = string
  default     = ""
  
  validation {
    condition     = var.environment == "" || contains(["dr", "stage", "prod"], var.environment)
    error_message = "Environment must be one of: dr, stage, prod, or empty (uses workspace)."
  }
}

# Solr Configuration
variable "solr_key_name" {
  description = "EC2 Key Pair name for Solr instances"
  type        = string
  default     = "solr-key"
}

variable "solr_private_key" {
  description = "Private key content (PEM format) for Solr cluster SSH access"
  type        = string
  default     = ""
  sensitive   = true
}

# Optional Overrides (if you want to override environment defaults)
variable "vpc_cidr_override" {
  description = "Override VPC CIDR block for the environment"
  type        = string
  default     = ""
}

variable "instance_type_override" {
  description = "Override Solr instance type for the environment"
  type        = string
  default     = ""
}

variable "cluster_size_override" {
  description = "Override Solr cluster size for the environment"
  type        = number
  default     = 0
}
