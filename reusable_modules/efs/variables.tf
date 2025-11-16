# File System Configuration
variable "name" {
  description = "Name of the EFS file system"
  type        = string
}

variable "creation_token" {
  description = "A unique name used as reference when creating the EFS file system"
  type        = string
  default     = null
}

variable "performance_mode" {
  description = "The file system performance mode"
  type        = string
  default     = "generalPurpose"
  validation {
    condition     = contains(["generalPurpose", "maxIO"], var.performance_mode)
    error_message = "Performance mode must be either 'generalPurpose' or 'maxIO'."
  }
}

variable "throughput_mode" {
  description = "Throughput mode for the file system"
  type        = string
  default     = "bursting"
  validation {
    condition     = contains(["bursting", "provisioned"], var.throughput_mode)
    error_message = "Throughput mode must be either 'bursting' or 'provisioned'."
  }
}

variable "provisioned_throughput_in_mibps" {
  description = "The throughput, measured in MiB/s, that you want to provision for the file system"
  type        = number
  default     = null
}

# Encryption Configuration
variable "encrypted" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN of the KMS key for encryption"
  type        = string
  default     = null
}

variable "create_kms_key" {
  description = "Create a KMS key for EFS encryption"
  type        = bool
  default     = false
}

variable "kms_key_policy" {
  description = "KMS key policy JSON"
  type        = string
  default     = null
}

variable "kms_key_deletion_window" {
  description = "KMS key deletion window in days"
  type        = number
  default     = 7
}

variable "enable_kms_key_rotation" {
  description = "Enable KMS key rotation"
  type        = bool
  default     = true
}

# Network Configuration
variable "subnet_ids" {
  description = "List of subnet IDs for mount targets"
  type        = list(string)
  default     = []
}

variable "security_group_ids" {
  description = "List of security group IDs for mount targets"
  type        = list(string)
  default     = []
}

variable "mount_target_ip_addresses" {
  description = "Map of subnet ID to IP address for mount targets"
  type        = map(string)
  default     = {}
}

# Lifecycle Policy
variable "lifecycle_policy" {
  description = "EFS lifecycle policy configuration"
  type = object({
    transition_to_ia                    = optional(string)
    transition_to_primary_storage_class = optional(string)
  })
  default = null
}

# Backup Configuration
variable "enable_backup_policy" {
  description = "Enable automatic backups"
  type        = bool
  default     = true
}

# Access Points Configuration
variable "access_points" {
  description = "Map of access points to create"
  type = map(object({
    posix_user = optional(object({
      gid            = number
      uid            = number
      secondary_gids = optional(list(number))
    }))
    root_directory = optional(object({
      path = string
      creation_info = optional(object({
        owner_gid   = number
        owner_uid   = number
        permissions = string
      }))
    }))
  }))
  default = {}
}

# File System Policy
variable "file_system_policy" {
  description = "EFS file system policy JSON"
  type        = string
  default     = null
}

variable "bypass_policy_lockout_safety_check" {
  description = "Bypass policy lockout safety check"
  type        = bool
  default     = false
}

# Replication Configuration
variable "replication_configuration" {
  description = "EFS replication configuration"
  type = object({
    destination_region     = string
    availability_zone_name = optional(string)
    kms_key_id            = optional(string)
  })
  default = null
}

# Tags
variable "tags" {
  description = "Map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}