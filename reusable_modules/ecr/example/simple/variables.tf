variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "ecr-example"
}

variable "repository_count" {
  description = "Number of private repositories to create"
  type        = number
  default     = 2
}

variable "enable_public_repository" {
  description = "Create a public ECR repository"
  type        = bool
  default     = true
}

variable "image_tag_mutability" {
  description = "Image tag mutability setting for repositories"
  type        = string
  default     = "MUTABLE"
  validation {
    condition     = contains(["MUTABLE", "IMMUTABLE"], var.image_tag_mutability)
    error_message = "Image tag mutability must be MUTABLE or IMMUTABLE."
  }
}

variable "scan_on_push" {
  description = "Enable image scanning on push"
  type        = bool
  default     = true
}

variable "force_delete" {
  description = "Force deletion of repositories even if they contain images"
  type        = bool
  default     = true
}

variable "create_iam_roles" {
  description = "Create IAM roles for ECR access"
  type        = bool
  default     = true
}

variable "lifecycle_policy_enabled" {
  description = "Enable lifecycle policy for image management"
  type        = bool
  default     = true
}

variable "production_image_count" {
  description = "Number of production images to keep"
  type        = number
  default     = 10
}

variable "untagged_image_days" {
  description = "Days to keep untagged images"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "ecr-example"
    Example     = "simple"
  }
}