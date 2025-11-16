variable "repository_names" {
  description = "List of ECR repository names"
  type        = list(string)
}

variable "repository_type" {
  description = "Type of ECR repository (private or public)"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "public"], var.repository_type)
    error_message = "Repository type must be private or public."
  }
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "force_delete" {
  description = "Force deletion of repository even if it contains images"
  type        = bool
  default     = false
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "encryption_type" {
  description = "Encryption type for repository"
  type        = string
  default     = "AES256"
  validation {
    condition     = contains(["AES256", "KMS"], var.encryption_type)
    error_message = "Encryption type must be AES256 or KMS."
  }
}

variable "kms_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "repository_policy" {
  description = "Repository policy JSON"
  type        = string
  default     = null
}

variable "lifecycle_policy" {
  description = "Lifecycle policy JSON"
  type        = string
  default     = null
}

variable "registry_policy" {
  description = "Registry policy JSON"
  type        = string
  default     = null
}

variable "registry_scan_type" {
  description = "Registry scanning type (BASIC or ENHANCED)"
  type        = string
  default     = null
  validation {
    condition     = var.registry_scan_type == null || contains(["BASIC", "ENHANCED"], var.registry_scan_type)
    error_message = "Registry scan type must be BASIC or ENHANCED."
  }
}

variable "registry_scan_rules" {
  description = "Registry scanning rules"
  type = list(object({
    scan_frequency = string
    repository_filter = object({
      filter      = string
      filter_type = string
    })
  }))
  default = []
}

variable "replication_configuration" {
  description = "Replication configuration"
  type = list(object({
    destinations = list(object({
      region      = string
      registry_id = string
    }))
    repository_filters = list(object({
      filter      = string
      filter_type = string
    }))
  }))
  default = []
}

variable "pull_through_cache_rules" {
  description = "Pull through cache rules"
  type = map(object({
    ecr_repository_prefix = string
    upstream_registry_url = string
    credential_arn       = optional(string)
  }))
  default = {}
}

variable "public_repository_catalog_data" {
  description = "Catalog data for public repositories"
  type = object({
    description      = optional(string)
    about_text       = optional(string)
    usage_text       = optional(string)
    operating_systems = optional(list(string))
    architectures    = optional(list(string))
    logo_image_blob  = optional(string)
  })
  default = {}
}

variable "tags" {
  description = "Tags to apply to ECR resources"
  type        = map(string)
  default     = {}
}

# IAM Variables
variable "create_pull_role" {
  description = "Create IAM role for ECR pull access"
  type        = bool
  default     = false
}

variable "create_push_role" {
  description = "Create IAM role for ECR push access"
  type        = bool
  default     = false
}

variable "pull_role_trusted_services" {
  description = "List of AWS services that can assume the pull role"
  type        = list(string)
  default     = ["ecs-tasks.amazonaws.com", "lambda.amazonaws.com"]
}

variable "push_role_trusted_services" {
  description = "List of AWS services that can assume the push role"
  type        = list(string)
  default     = ["codebuild.amazonaws.com"]
}

variable "push_role_trusted_principals" {
  description = "List of AWS principals (ARNs) that can assume the push role"
  type        = list(string)
  default     = []
}

variable "pull_role_additional_policy_arns" {
  description = "Additional policy ARNs to attach to the pull role"
  type        = list(string)
  default     = []
}

variable "push_role_additional_policy_arns" {
  description = "Additional policy ARNs to attach to the push role"
  type        = list(string)
  default     = []
}