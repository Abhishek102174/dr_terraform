# Cluster Configuration
variable "cluster_name" {
  description = "Name of the MemoryDB cluster"
  type        = string
}

variable "cluster_description" {
  description = "Description of the MemoryDB cluster"
  type        = string
  default     = null
}

variable "node_type" {
  description = "Instance class to use for the cluster nodes"
  type        = string
  default     = "db.t4g.small"
}

variable "num_shards" {
  description = "Number of shards in the cluster"
  type        = number
  default     = 1
}

variable "num_replicas_per_shard" {
  description = "Number of replicas per shard"
  type        = number
  default     = 1
}

variable "port" {
  description = "Port number on which the cluster accepts connections"
  type        = number
  default     = 6379
}

variable "engine_version" {
  description = "Version number of the Redis engine"
  type        = string
  default     = "7.0"
}

variable "maintenance_window" {
  description = "Weekly time range for system maintenance"
  type        = string
  default     = "sun:23:00-mon:01:30"
}

variable "snapshot_retention_limit" {
  description = "Number of days for which MemoryDB retains automatic snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily time range for automatic snapshots"
  type        = string
  default     = "05:00-09:00"
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "data_tiering" {
  description = "Enable data tiering"
  type        = bool
  default     = false
}

variable "tls_enabled" {
  description = "Enable TLS encryption"
  type        = bool
  default     = true
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic to send notifications to"
  type        = string
  default     = null
}

# Network Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for the subnet group (required - minimum 2 subnets)"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs must be provided for MemoryDB cluster."
  }
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the cluster"
  type        = list(string)
  default     = []
}

# Subnet Group
variable "create_subnet_group" {
  description = "Create a subnet group for the cluster (recommended unless using existing subnet group)"
  type        = bool
  default     = true
}

variable "subnet_group_name" {
  description = "Name of the subnet group"
  type        = string
  default     = null
}

# Parameter Group
variable "create_parameter_group" {
  description = "Create a parameter group for the cluster"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Name of the parameter group"
  type        = string
  default     = null
}

variable "parameter_group_family" {
  description = "Parameter group family"
  type        = string
  default     = "memorydb_redis7"
}

variable "parameter_group_description" {
  description = "Description of the parameter group"
  type        = string
  default     = "MemoryDB parameter group"
}

variable "parameters" {
  description = "List of parameters to apply to the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

# ACL Configuration
variable "create_acl" {
  description = "Create an ACL for the cluster"
  type        = bool
  default     = false
}

variable "acl_name" {
  description = "Name of the ACL"
  type        = string
  default     = "open-access"
}

variable "acl_user_names" {
  description = "List of user names to associate with the ACL"
  type        = list(string)
  default     = ["default"]
}

# Users Configuration
variable "users" {
  description = "Map of users to create"
  type = map(object({
    access_string = string
    authentication_mode = object({
      type      = string
      passwords = list(string)
    })
  }))
  default = {}
  validation {
    condition = alltrue([
      for user in var.users : contains(["password", "iam"], user.authentication_mode.type)
    ])
    error_message = "Authentication mode type must be 'password' or 'iam'."
  }
}

# Snapshot Configuration
variable "create_snapshot" {
  description = "Create a snapshot of the cluster"
  type        = bool
  default     = false
}

variable "snapshot_name" {
  description = "Name of the snapshot"
  type        = string
  default     = null
}

# Encryption
variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption at rest"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}