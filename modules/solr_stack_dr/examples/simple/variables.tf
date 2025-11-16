# Example Variables for Solr Stack DR

variable "aws_region" {
  description = "AWS region for DR deployment"
  type        = string
  default     = "us-west-2"
}

variable "name_prefix" {
  description = "Prefix for all resource names"
  type        = string
  default     = "solr-dr-example"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.201.0.0/20"
}

variable "key_name" {
  description = "EC2 Key Pair name for SSH access"
  type        = string
  default     = "solr-dr-key"
}

variable "instance_type" {
  description = "EC2 instance type for Solr nodes"
  type        = string
  default     = "m5.xlarge"
}

variable "cluster_size" {
  description = "Number of Solr nodes in the cluster"
  type        = number
  default     = 3
}

variable "data_volume_size" {
  description = "Size of data volume in GB"
  type        = number
  default     = 50
}

variable "data_volume_iops" {
  description = "IOPS for data volume"
  type        = number
  default     = 150
}

variable "health_check_grace_period" {
  description = "Health check grace period in seconds"
  type        = number
  default     = 1200
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancer"
  type        = bool
  default     = false  # Disabled for example
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default = {
    Environment     = "dr-example"
    Service         = "solr"
    ManagedBy      = "terraform"
    Purpose        = "disaster-recovery-example"
    Owner          = "devops-team"
  }
}
