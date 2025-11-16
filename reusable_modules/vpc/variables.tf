# Basic VPC Configuration
variable "name" {
  description = "Name of the VPC"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Enable DNS support in the VPC"
  type        = bool
  default     = true
}

# Internet Gateway
variable "create_igw" {
  description = "Create Internet Gateway"
  type        = bool
  default     = false
}

# NAT Gateway
variable "create_nat_gateway" {
  description = "Create NAT Gateway for private subnets"
  type        = bool
  default     = false
}

# Public Subnets
variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}

# Private Subnets
variable "private_subnets" {
  description = "List of private subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = []
}

# Tags
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# DHCP Options
variable "create_dhcp_options" {
  description = "Create DHCP options set"
  type        = bool
  default     = false
}

variable "dhcp_options_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = ""
}

variable "dhcp_options_domain_name_servers" {
  description = "Domain name servers for DHCP options"
  type        = list(string)
  default     = ["AmazonProvidedDNS"]
}

# Transit Gateway
variable "create_tgw" {
  description = "Create Transit Gateway"
  type        = bool
  default     = false
}

variable "tgw_description" {
  description = "Description for Transit Gateway"
  type        = string
  default     = "Transit Gateway"
}

variable "tgw_default_route_table_association" {
  description = "Enable default route table association"
  type        = string
  default     = "enable"
}

variable "tgw_default_route_table_propagation" {
  description = "Enable default route table propagation"
  type        = string
  default     = "enable"
}

variable "tgw_subnet_ids" {
  description = "Subnet IDs for TGW attachment (defaults to private subnets)"
  type        = list(string)
  default     = null
}

variable "create_tgw_route_table" {
  description = "Create Transit Gateway route table"
  type        = bool
  default     = false
}

# VPC Endpoints
variable "vpc_endpoints_gateway" {
  description = "Gateway VPC endpoints configuration"
  type = map(object({
    service_name    = string
    route_table_ids = list(string)
  }))
  default = {}
}

variable "vpc_endpoints_interface" {
  description = "Interface VPC endpoints configuration"
  type = map(object({
    service_name        = string
    subnet_ids          = list(string)
    security_group_ids  = list(string)
    private_dns_enabled = bool
  }))
  default = {}
}

# VPC Endpoints Security Group Rules
variable "vpc_endpoints_sg_ingress_rules" {
  description = "Ingress rules for VPC endpoints security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = []
      description = "HTTPS from VPC"
    }
  ]
}

variable "vpc_endpoints_sg_egress_rules" {
  description = "Egress rules for VPC endpoints security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic"
    }
  ]
}