variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "namespace" {
  type        = string
  description = "Namespace for the resources"
  default     = "company"
}

variable "environment" {
  type        = string
  description = "Environment name"
  default     = "dev"
}

variable "stage" {
  type        = string
  description = "Stage name"
  default     = "test"
}

variable "name" {
  type        = string
  description = "Name of the project/application"
  default     = "iam-demo"
}

variable "project_name" {
  type        = string
  description = "Name of the project"
  default     = "IAM-Demo-Project"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository for OIDC (format: owner/repo)"
  default     = "myorg/myrepo"
}
