# VPC Module Variables - DR Network Configuration

variable "vpc_name" {
  description = "Name of the DR VPC"
  type        = string
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]+$", var.vpc_name))
    error_message = "VPC name must contain only alphanumeric characters and hyphens."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the DR VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "tags" {
  description = "Tags to apply to all VPC resources"
  type        = map(string)
  default     = {}
}
