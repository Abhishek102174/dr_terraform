# Basic Table Configuration
variable "table_name" {
  description = "Name of the DynamoDB table"
  type        = string
}

variable "billing_mode" {
  description = "Billing mode for the table (PAY_PER_REQUEST or PROVISIONED)"
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "hash_key" {
  description = "Hash key (partition key) for the table"
  type        = string
}

variable "range_key" {
  description = "Range key (sort key) for the table"
  type        = string
  default     = null
}

variable "read_capacity" {
  description = "Read capacity units (required for PROVISIONED billing mode)"
  type        = number
  default     = null
}

variable "write_capacity" {
  description = "Write capacity units (required for PROVISIONED billing mode)"
  type        = number
  default     = null
}

variable "table_class" {
  description = "Storage class of the table (STANDARD or STANDARD_INFREQUENT_ACCESS)"
  type        = string
  default     = "STANDARD"
}

variable "deletion_protection_enabled" {
  description = "Enable deletion protection for the table"
  type        = bool
  default     = false
}

# Table Attributes
variable "attributes" {
  description = "List of table attributes"
  type = list(object({
    name = string
    type = string
  }))
}

# Global Secondary Indexes
variable "global_secondary_indexes" {
  description = "List of global secondary indexes"
  type = list(object({
    name               = string
    hash_key          = string
    range_key         = optional(string)
    projection_type   = string
    non_key_attributes = optional(list(string))
    read_capacity     = optional(number)
    write_capacity    = optional(number)
  }))
  default = []
}

# Local Secondary Indexes
variable "local_secondary_indexes" {
  description = "List of local secondary indexes"
  type = list(object({
    name               = string
    range_key         = string
    projection_type   = string
    non_key_attributes = optional(list(string))
  }))
  default = []
}

# Encryption
variable "server_side_encryption_enabled" {
  description = "Enable server-side encryption"
  type        = bool
  default     = false
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Point-in-time Recovery
variable "point_in_time_recovery_enabled" {
  description = "Enable point-in-time recovery"
  type        = bool
  default     = false
}

# Streams
variable "stream_enabled" {
  description = "Enable DynamoDB Streams"
  type        = bool
  default     = false
}

variable "stream_view_type" {
  description = "Stream view type (KEYS_ONLY, NEW_IMAGE, OLD_IMAGE, NEW_AND_OLD_IMAGES)"
  type        = string
  default     = "NEW_AND_OLD_IMAGES"
}

# TTL
variable "ttl_enabled" {
  description = "Enable TTL for the table"
  type        = bool
  default     = false
}

variable "ttl_attribute_name" {
  description = "Name of the TTL attribute"
  type        = string
  default     = null
}



# Auto Scaling
variable "auto_scaling_enabled" {
  description = "Enable auto-scaling for the table"
  type        = bool
  default     = false
}

variable "auto_scaling_read_min_capacity" {
  description = "Minimum read capacity for auto-scaling"
  type        = number
  default     = null
}

variable "auto_scaling_read_max_capacity" {
  description = "Maximum read capacity for auto-scaling"
  type        = number
  default     = null
}

variable "auto_scaling_read_target_value" {
  description = "Target utilization for read capacity auto-scaling"
  type        = number
  default     = 70.0
}

variable "auto_scaling_write_min_capacity" {
  description = "Minimum write capacity for auto-scaling"
  type        = number
  default     = null
}

variable "auto_scaling_write_max_capacity" {
  description = "Maximum write capacity for auto-scaling"
  type        = number
  default     = null
}

variable "auto_scaling_write_target_value" {
  description = "Target utilization for write capacity auto-scaling"
  type        = number
  default     = 70.0
}

# Replica/Global Table Configuration
variable "replica_regions" {
  description = "List of regions for DynamoDB global table replicas (empty list means no replicas)"
  type        = list(string)
  default     = []
}

variable "global_table_enabled" {
  description = "Enable global table functionality"
  type        = bool
  default     = false
}





# Enhanced Auto Scaling for GSI
variable "gsi_auto_scaling_enabled" {
  description = "Enable auto-scaling for Global Secondary Indexes"
  type        = bool
  default     = false
}

variable "gsi_auto_scaling_read_min_capacity" {
  description = "Minimum read capacity for GSI auto-scaling"
  type        = number
  default     = null
}

variable "gsi_auto_scaling_read_max_capacity" {
  description = "Maximum read capacity for GSI auto-scaling"
  type        = number
  default     = null
}

variable "gsi_auto_scaling_write_min_capacity" {
  description = "Minimum write capacity for GSI auto-scaling"
  type        = number
  default     = null
}

variable "gsi_auto_scaling_write_max_capacity" {
  description = "Maximum write capacity for GSI auto-scaling"
  type        = number
  default     = null
}

# Tags
variable "tags" {
  description = "Tags to apply to the table"
  type        = map(string)
  default     = {}
}