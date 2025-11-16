# Comprehensive VPC example showcasing all module features
module "vpc" {
  source = "../../"

  name       = var.vpc_name
  cidr_block = var.vpc_cidr_block

  # DNS settings
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  # Internet connectivity
  create_igw         = var.create_igw
  create_nat_gateway = var.create_nat_gateway

  # Subnets configuration
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets

  # DHCP Options
  create_dhcp_options              = var.create_dhcp_options
  dhcp_options_domain_name         = var.dhcp_options_domain_name
  dhcp_options_domain_name_servers = var.dhcp_options_domain_name_servers

  # Transit Gateway
  create_tgw                           = var.create_tgw
  tgw_description                      = var.tgw_description
  tgw_default_route_table_association  = var.tgw_default_route_table_association
  tgw_default_route_table_propagation  = var.tgw_default_route_table_propagation
  create_tgw_route_table              = var.create_tgw_route_table

  # VPC Endpoints - Gateway
  vpc_endpoints_gateway = var.enable_vpc_endpoints ? {
    s3 = {
      service_name    = "com.amazonaws.${var.region}.s3"
      route_table_ids = [] # Will be populated dynamically by module
    }
    dynamodb = {
      service_name    = "com.amazonaws.${var.region}.dynamodb"
      route_table_ids = [] # Will be populated dynamically by module
    }
  } : {}

  # VPC Endpoints - Interface
  vpc_endpoints_interface = var.enable_vpc_endpoints ? {
    ec2 = {
      service_name        = "com.amazonaws.${var.region}.ec2"
      subnet_ids          = [] # Will be populated dynamically by module
      security_group_ids  = [] # Will use built-in VPC endpoints security group
      private_dns_enabled = true
    }
    ssm = {
      service_name        = "com.amazonaws.${var.region}.ssm"
      subnet_ids          = [] # Will be populated dynamically by module
      security_group_ids  = [] # Will use built-in VPC endpoints security group
      private_dns_enabled = true
    }
    ec2messages = {
      service_name        = "com.amazonaws.${var.region}.ec2messages"
      subnet_ids          = [] # Will be populated dynamically by module
      security_group_ids  = [] # Will use built-in VPC endpoints security group
      private_dns_enabled = true
    }
    kms = {
      service_name        = "com.amazonaws.${var.region}.kms"
      subnet_ids          = [] # Will be populated dynamically by module
      security_group_ids  = [] # Will use built-in VPC endpoints security group
      private_dns_enabled = true
    }
    logs = {
      service_name        = "com.amazonaws.${var.region}.logs"
      subnet_ids          = [] # Will be populated dynamically by module
      security_group_ids  = [] # Will use built-in VPC endpoints security group
      private_dns_enabled = true
    }
  } : {}

  # VPC Endpoints Security Group Rules
  vpc_endpoints_sg_ingress_rules = var.vpc_endpoints_sg_ingress_rules
  vpc_endpoints_sg_egress_rules  = var.vpc_endpoints_sg_egress_rules

  tags = var.tags
}