variable "region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "example-vpc"
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
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

variable "create_igw" {
  description = "Create Internet Gateway"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Create NAT Gateway for private subnets"
  type        = bool
  default     = true
}

variable "public_subnets" {
  description = "List of public subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  ]
}

variable "private_subnets" {
  description = "List of private subnets"
  type = list(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = [
    {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1b"
    }
  ]
}

# DHCP Options
variable "create_dhcp_options" {
  description = "Create DHCP options set"
  type        = bool
  default     = true
}

variable "dhcp_options_domain_name" {
  description = "Domain name for DHCP options"
  type        = string
  default     = "ec2.internal"
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
  default     = true
}

variable "tgw_description" {
  description = "Description for Transit Gateway"
  type        = string
  default     = "Example Transit Gateway"
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

variable "create_tgw_route_table" {
  description = "Create Transit Gateway route table"
  type        = bool
  default     = true
}

# VPC Endpoints
variable "enable_vpc_endpoints" {
  description = "Enable VPC endpoints"
  type        = bool
  default     = true
}

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
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = []
      description = "HTTP from VPC"
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

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "vpc-example"
    Example     = "comprehensive"
  }
}