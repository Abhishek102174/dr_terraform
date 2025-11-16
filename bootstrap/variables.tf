variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "dr"
}

variable "environment" {
  description = "Environment name (dr, stage, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
