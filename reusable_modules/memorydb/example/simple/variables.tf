variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "memorydb-example"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the MemoryDB cluster (minimum 2 required)"
  type        = list(string)
  default     = ["subnet-12345678", "subnet-87654321"]
}

variable "security_group_ids" {
  description = "List of security group IDs for the MemoryDB cluster"
  type        = list(string)
  default     = ["sg-12345678"]
}

variable "node_type" {
  description = "Instance class for the cluster nodes"
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

variable "engine_version" {
  description = "Redis engine version"
  type        = string
  default     = "7.0"
}

variable "port" {
  description = "Port for the cluster"
  type        = number
  default     = 6379
}

variable "tls_enabled" {
  description = "Enable TLS encryption"
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "maintenance_window" {
  description = "Weekly maintenance window"
  type        = string
  default     = "sun:23:00-mon:01:30"
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily snapshot window"
  type        = string
  default     = "05:00-09:00"
}

variable "create_subnet_group" {
  description = "Create subnet group"
  type        = bool
  default     = true
}

variable "subnet_group_name" {
  description = "Name of the subnet group"
  type        = string
  default     = null
}

variable "create_parameter_group" {
  description = "Create parameter group"
  type        = bool
  default     = true
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
  description = "Parameter group description"
  type        = string
  default     = "Example MemoryDB parameter group"
}

variable "parameters" {
  description = "List of parameters for the parameter group"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]
}

variable "create_acl" {
  description = "Create ACL"
  type        = bool
  default     = true
}

variable "acl_name" {
  description = "Name of the ACL"
  type        = string
  default     = null
}

variable "users" {
  description = "Map of users to create"
  type = map(object({
    access_string = string
    authentication_mode = object({
      type      = string
      passwords = list(string)
    })
  }))
  default = {
    "app-user" = {
      access_string = "on ~* &* +@all"
      authentication_mode = {
        type      = "password"
        passwords = ["password123!"]
      }
    }
  }
}

variable "create_snapshot" {
  description = "Create snapshot"
  type        = bool
  default     = false
}

variable "snapshot_name" {
  description = "Name of the snapshot"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "example"
    Service     = "cache"
    Purpose     = "memorydb-testing"
  }
}