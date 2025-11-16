# Deployment Configuration
variable "deployment_type" {
  description = "Deployment type: provisioned or serverless"
  type        = string
  default     = "provisioned"
  validation {
    condition     = contains(["provisioned", "serverless"], var.deployment_type)
    error_message = "Deployment type must be 'provisioned' or 'serverless'."
  }
}

# Domain Configuration
variable "domain_name" {
  description = "Name of the OpenSearch domain or collection"
  type        = string
}

variable "engine_version" {
  description = "OpenSearch engine version (provisioned only)"
  type        = string
  default     = "OpenSearch_2.3"
}

# Serverless Configuration
variable "collection_type" {
  description = "Type of serverless collection (SEARCH, TIMESERIES, VECTORSEARCH)"
  type        = string
  default     = "SEARCH"
  validation {
    condition     = contains(["SEARCH", "TIMESERIES", "VECTORSEARCH"], var.collection_type)
    error_message = "Collection type must be SEARCH, TIMESERIES, or VECTORSEARCH."
  }
}

variable "description" {
  description = "Description of the collection (serverless only)"
  type        = string
  default     = null
}

variable "create_encryption_policy" {
  description = "Create encryption security policy (serverless only)"
  type        = bool
  default     = true
}

variable "use_aws_owned_key" {
  description = "Use AWS owned key for encryption (serverless only)"
  type        = bool
  default     = true
}

variable "create_network_policy" {
  description = "Create network security policy (serverless only)"
  type        = bool
  default     = true
}

variable "allow_from_public" {
  description = "Allow access from public internet (serverless only)"
  type        = bool
  default     = false
}

variable "create_data_access_policy" {
  description = "Create data access policy (serverless only)"
  type        = bool
  default     = true
}

variable "data_access_permissions" {
  description = "Data access permissions for the collection (serverless only)"
  type        = list(string)
  default     = ["aoss:*"]
}

variable "index_permissions" {
  description = "Index permissions (serverless only)"
  type        = list(string)
  default     = ["aoss:*"]
}

variable "data_access_principals" {
  description = "List of principals for data access (serverless only)"
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "VPC ID for VPC endpoint (serverless only)"
  type        = string
  default     = null
}

variable "vpc_endpoint_ids" {
  description = "List of VPC endpoint IDs for network policy (serverless only)"
  type        = list(string)
  default     = []
}

variable "error_logs_enabled" {
  description = "Enable error logs (serverless only)"
  type        = bool
  default     = false
}

# Cluster Configuration
variable "instance_type" {
  description = "Instance type for OpenSearch cluster nodes"
  type        = string
  default     = "t3.small.search"
}

variable "instance_count" {
  description = "Number of instances in the cluster"
  type        = number
  default     = 1
}

variable "dedicated_master_enabled" {
  description = "Enable dedicated master nodes"
  type        = bool
  default     = false
}

variable "dedicated_master_type" {
  description = "Instance type for dedicated master nodes"
  type        = string
  default     = "t3.small.search"
}

variable "dedicated_master_count" {
  description = "Number of dedicated master nodes"
  type        = number
  default     = 3
  validation {
    condition     = contains([3, 5], var.dedicated_master_count)
    error_message = "Dedicated master count must be 3 or 5."
  }
}

variable "zone_awareness_enabled" {
  description = "Enable zone awareness for the cluster"
  type        = bool
  default     = false
}

variable "availability_zone_count" {
  description = "Number of availability zones for zone awareness"
  type        = number
  default     = 2
  validation {
    condition     = contains([2, 3], var.availability_zone_count)
    error_message = "Availability zone count must be 2 or 3."
  }
}

variable "warm_enabled" {
  description = "Enable warm storage"
  type        = bool
  default     = false
}

variable "warm_count" {
  description = "Number of warm nodes"
  type        = number
  default     = 2
}

variable "warm_type" {
  description = "Instance type for warm nodes"
  type        = string
  default     = "ultrawarm1.medium.search"
}

variable "cold_storage_enabled" {
  description = "Enable cold storage"
  type        = bool
  default     = false
}

# EBS Configuration
variable "ebs_enabled" {
  description = "Enable EBS volumes"
  type        = bool
  default     = true
}

variable "volume_type" {
  description = "EBS volume type"
  type        = string
  default     = "gp3"
  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2"], var.volume_type)
    error_message = "Volume type must be gp2, gp3, io1, or io2."
  }
}

variable "volume_size" {
  description = "EBS volume size in GB"
  type        = number
  default     = 20
}

variable "iops" {
  description = "IOPS for io1/io2 volumes"
  type        = number
  default     = null
}

variable "throughput" {
  description = "Throughput for gp3 volumes"
  type        = number
  default     = null
}

# Network Configuration
variable "vpc_enabled" {
  description = "Enable VPC for the domain"
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "List of subnet IDs for VPC deployment"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs (manual approach)"
  type        = list(string)
  default     = null
}

variable "security_group_id" {
  description = "Security group ID from module output"
  type        = string
  default     = null
}

variable "vpc_module_subnet_ids" {
  description = "Subnet IDs from VPC module output (private_subnet_ids)"
  type        = list(string)
  default     = null
}

# Encryption Configuration
variable "encrypt_at_rest" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "KMS key ID for encryption at rest"
  type        = string
  default     = null
}

variable "node_to_node_encryption" {
  description = "Enable node-to-node encryption"
  type        = bool
  default     = true
}

variable "enforce_https" {
  description = "Enforce HTTPS for domain endpoint"
  type        = bool
  default     = true
}

variable "tls_security_policy" {
  description = "TLS security policy"
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

# Advanced Security Options
variable "advanced_security_enabled" {
  description = "Enable advanced security options"
  type        = bool
  default     = false
}

variable "anonymous_auth_enabled" {
  description = "Enable anonymous authentication"
  type        = bool
  default     = false
}

variable "internal_user_database_enabled" {
  description = "Enable internal user database"
  type        = bool
  default     = false
}

variable "master_user_name" {
  description = "Master user name for internal user database"
  type        = string
  default     = null
}

variable "master_user_password" {
  description = "Master user password for internal user database"
  type        = string
  default     = null
  sensitive   = true
}

# Logging Configuration
variable "index_slow_logs_enabled" {
  description = "Enable index slow logs"
  type        = bool
  default     = false
}

variable "search_slow_logs_enabled" {
  description = "Enable search slow logs"
  type        = bool
  default     = false
}

variable "es_application_logs_enabled" {
  description = "Enable ES application logs"
  type        = bool
  default     = false
}

variable "audit_logs_enabled" {
  description = "Enable audit logs (both provisioned and serverless)"
  type        = bool
  default     = false
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 14
}

variable "log_kms_key_id" {
  description = "KMS key ID for CloudWatch log encryption"
  type        = string
  default     = null
}

variable "create_log_resource_policy" {
  description = "Create CloudWatch log resource policy"
  type        = bool
  default     = true
}

# Snapshot Configuration
variable "automated_snapshot_start_hour" {
  description = "Hour when automated snapshots are taken"
  type        = number
  default     = 0
  validation {
    condition     = var.automated_snapshot_start_hour >= 0 && var.automated_snapshot_start_hour <= 23
    error_message = "Snapshot start hour must be between 0 and 23."
  }
}

# Auto-Tune Configuration
variable "auto_tune_desired_state" {
  description = "Auto-Tune desired state"
  type        = string
  default     = "ENABLED"
  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.auto_tune_desired_state)
    error_message = "Auto-Tune desired state must be ENABLED or DISABLED."
  }
}

variable "auto_tune_rollback_on_disable" {
  description = "Rollback on disable for Auto-Tune"
  type        = string
  default     = "NO_ROLLBACK"
  validation {
    condition     = contains(["NO_ROLLBACK", "DEFAULT_ROLLBACK"], var.auto_tune_rollback_on_disable)
    error_message = "Auto-Tune rollback must be NO_ROLLBACK or DEFAULT_ROLLBACK."
  }
}

variable "auto_tune_maintenance_schedule" {
  description = "Auto-Tune maintenance schedule"
  type = list(object({
    start_at         = string
    duration_value   = number
    duration_unit    = string
    cron_expression  = string
  }))
  default = []
}

# Advanced Options
variable "advanced_options" {
  description = "Advanced options for the domain"
  type        = map(string)
  default     = {}
}

# AI/ML Options
variable "aiml_options" {
  description = "AI/ML options for the domain"
  type = object({
    natural_language_query_generation_options = optional(object({
      desired_state = string
    }))
    s3_vectors_engine = optional(object({
      enabled = bool
    }))
  })
  default = null
}

# Domain Policy
variable "domain_policy" {
  description = "Domain access policy JSON"
  type        = string
  default     = null
}

variable "create_access_policy_document" {
  description = "Create access policy using IAM policy document instead of raw JSON"
  type        = bool
  default     = false
}

variable "use_separate_policy_resource" {
  description = "Use separate domain policy resource instead of inline access_policies"
  type        = bool
  default     = false
}

variable "access_policy_source_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document"
  type        = list(string)
  default     = []
}

variable "access_policy_override_policy_documents" {
  description = "List of IAM policy documents that are merged together into the exported document with higher precedence"
  type        = list(string)
  default     = []
}

variable "access_policy_statements" {
  description = "A list of IAM policy statements for custom access policy"
  type        = any
  default     = []
}

# VPC Endpoint Configuration
variable "create_vpc_endpoint" {
  description = "Create VPC endpoint for private access"
  type        = bool
  default     = false
}

variable "vpc_endpoint_subnet_ids" {
  description = "List of subnet IDs for VPC endpoint"
  type        = list(string)
  default     = []
}

variable "vpc_endpoint_security_group_ids" {
  description = "List of security group IDs for VPC endpoint"
  type        = list(string)
  default     = []
}

# KMS Configuration
variable "create_kms_key" {
  description = "Create custom KMS key for encryption (if false, uses AWS managed key)"
  type        = bool
  default     = false
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 30
  validation {
    condition     = var.kms_key_deletion_window >= 7 && var.kms_key_deletion_window <= 30
    error_message = "KMS key deletion window must be between 7 and 30 days."
  }
}

variable "enable_kms_key_rotation" {
  description = "Enable automatic KMS key rotation"
  type        = bool
  default     = true
}

variable "kms_key_policy" {
  description = "Custom KMS key policy JSON (if not provided, uses default policy)"
  type        = string
  default     = null
}

# Package Configuration
variable "packages" {
  description = "Map of packages to associate with the domain"
  type = map(object({
    package_id = string
  }))
  default = {}
}

# SAML Configuration
variable "saml_enabled" {
  description = "Enable SAML authentication"
  type        = bool
  default     = false
}

variable "saml_entity_id" {
  description = "SAML entity ID"
  type        = string
  default     = null
}

variable "saml_metadata_content" {
  description = "SAML metadata content"
  type        = string
  default     = null
}

variable "saml_master_backend_role" {
  description = "SAML master backend role"
  type        = string
  default     = null
}

variable "saml_master_user_name" {
  description = "SAML master user name"
  type        = string
  default     = null
}

variable "saml_roles_key" {
  description = "SAML roles key"
  type        = string
  default     = null
}

variable "saml_session_timeout_minutes" {
  description = "SAML session timeout in minutes"
  type        = number
  default     = 60
}

variable "saml_subject_key" {
  description = "SAML subject key"
  type        = string
  default     = null
}

# IAM Configuration
variable "create_service_linked_role" {
  description = "Create service linked role for OpenSearch"
  type        = bool
  default     = false
}

# Tags
variable "tags" {
  description = "Map of tags to assign to resources"
  type        = map(string)
  default     = {}
}