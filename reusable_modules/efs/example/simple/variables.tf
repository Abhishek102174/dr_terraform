variable "subnet_ids" {
  description = "List of subnet IDs where EFS mount targets will be created"
  type        = list(string)
  default     = ["subnet-12345678", "subnet-87654321"]
}

variable "security_group_ids" {
  description = "List of security group IDs for EFS mount targets"
  type        = list(string)
  default     = ["sg-12345678"]
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

