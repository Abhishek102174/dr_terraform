# =============================================================================
# SOLR STACK DR MODULE VARIABLES (Refactored)
# =============================================================================

# Basic Configuration
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where Solr resources will be created"
  type        = string
}

variable "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  type        = string
}

variable "subnet_cidr_base" {
  description = "Base CIDR block for Solr subnets"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Networking Module Inputs (from networking module outputs)
variable "internet_gateway_id" {
  description = "Internet Gateway ID from networking module"
  type        = string
  default     = ""
}

variable "nat_gateway_ids" {
  description = "List of NAT Gateway IDs from networking module"
  type        = list(string)
  default     = []
}

variable "transit_gateway_routes" {
  description = "List of Transit Gateway routes for Solr subnets"
  type = list(object({
    cidr_block         = string
    transit_gateway_id = string
  }))
  default = []
}

variable "vpc_peering_routes" {
  description = "List of VPC Peering routes for Solr subnets"
  type = list(object({
    cidr_block                = string
    vpc_peering_connection_id = string
  }))
  default = []
}

# Solr Configuration
variable "key_name" {
  description = "EC2 Key Pair name for Solr instances (will be created if doesn't exist)"
  type        = string
}

variable "solr_private_key" {
  description = "Private key content (PEM format) for Solr cluster SSH access"
  type        = string
  sensitive   = true
}

variable "solr_public_key" {
  description = "Public key (OpenSSH format) for AWS key pair import; used if provided"
  type        = string
  default     = ""
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

variable "ami_id" {
  description = "AMI ID for Solr instances (optional - will use latest if not provided)"
  type        = string
  default     = ""
}

# Storage Configuration
variable "root_volume_size" {
  description = "Size of root volume in GB"
  type        = number
  default     = 100
}

variable "data_volume_size" {
  description = "Size of Solr data volume in GB"
  type        = number
  default     = 50
}

variable "data_volume_iops" {
  description = "IOPS for Solr data volume"
  type        = number
  default     = 150
}

# Security Configuration
variable "on_premises_cidrs" {
  description = "List of on-premises CIDR blocks for SSH and monitoring access"
  type        = list(string)
  default = [
    "10.242.128.0/17",
    "10.2.0.0/16", 
    "10.242.0.0/17",
    "10.249.200.0/21",
    "10.104.0.0/16",
    "10.135.208.0/20",
    "10.105.0.0/16",
    "10.231.0.0/16",
    "10.216.0.0/16",
    "10.201.11.0/24"
  ]
}

variable "cross_environment_cidrs" {
  description = "CIDR blocks for cross-environment Solr indexing access"
  type        = list(string)
  default = [
    "10.201.1.128/25",
    "10.200.51.0/25",
    "10.200.51.128/25",
    "10.216.0.0/16"
  ]
}

# EFS Configuration
variable "efs_provisioned_throughput" {
  description = "Provisioned throughput for EFS in MiB/s"
  type        = number
  default     = 100
}

# Operational Settings
variable "health_check_grace_period" {
  description = "Health check grace period for ASG"
  type        = number
  default     = 1200
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection for load balancer"
  type        = bool
  default     = true
}

variable "user_data" {
  description = "User data script for Solr instance initialization"
  type        = string
  default     = ""
}
variable "solr_fallback_ami_id" {
  description = "Fallback AMI ID to use if latest Solr AMI is not found"
  type        = string
  default     = ""
}
