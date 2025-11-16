# =============================================================================
# NETWORKING MODULE VARIABLES
# =============================================================================

# Basic Configuration
variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where networking resources will be created"
  type        = string
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# Internet Gateway Configuration
variable "create_igw" {
  description = "Whether to create an Internet Gateway"
  type        = bool
  default     = true
}

# NAT Gateway Configuration
variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create (typically one per AZ)"
  type        = number
  default     = 3
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs where NAT Gateways will be placed"
  type        = list(string)
  default     = []
}

# Transit Gateway Configuration
variable "create_tgw" {
  description = "Whether to create a Transit Gateway"
  type        = bool
  default     = false
}

variable "tgw_description" {
  description = "Description for the Transit Gateway"
  type        = string
  default     = "Transit Gateway for DR infrastructure"
}

variable "tgw_default_route_table_association" {
  description = "Enable default route table association for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_default_route_table_propagation" {
  description = "Enable default route table propagation for TGW"
  type        = string
  default     = "enable"
}

variable "tgw_amazon_side_asn" {
  description = "Amazon side ASN for Transit Gateway"
  type        = number
  default     = 64512
}

variable "tgw_subnet_ids" {
  description = "List of subnet IDs for TGW attachment"
  type        = list(string)
  default     = []
}

variable "create_tgw_route_table" {
  description = "Whether to create a custom TGW route table"
  type        = bool
  default     = false
}
