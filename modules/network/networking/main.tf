# =============================================================================
# NETWORKING MODULE - Fully Using Reusable VPC Module
# =============================================================================
# This module creates core networking infrastructure using the reusable VPC module
# for ALL networking components: IGW, NAT Gateway, EIP, and Transit Gateway
# =============================================================================

# -----------------------------------------------------------------------------
# DATA SOURCES
# -----------------------------------------------------------------------------

# Get available AZs for multi-zone deployment
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# NETWORKING INFRASTRUCTURE - Using reusable VPC module
# -----------------------------------------------------------------------------

module "networking_components" {
  source = "../../../../reusable_modules/vpc"
  
  # Use existing VPC - don't create new one
  name       = "${var.name_prefix}-networking"
  cidr_block = "10.0.0.0/8"  # Dummy CIDR, won't be used since we're not creating VPC
  
  # Create networking components
  create_igw         = var.create_igw
  create_nat_gateway = var.create_nat_gateways
  create_tgw         = var.create_tgw
  create_tgw_route_table = var.create_tgw_route_table
  
  # Transit Gateway configuration
  tgw_description                     = var.tgw_description
  tgw_default_route_table_association = var.tgw_default_route_table_association
  tgw_default_route_table_propagation = var.tgw_default_route_table_propagation
  tgw_amazon_side_asn                 = var.tgw_amazon_side_asn
  tgw_subnet_ids                      = var.tgw_subnet_ids
  
  # Define public subnets for NAT Gateway placement
  public_subnets = var.create_nat_gateways ? [
    for i in range(var.nat_gateway_count) : {
      cidr_block        = "10.200.${240 + i}.0/28"  # Small subnets for NAT gateways
      availability_zone = data.aws_availability_zones.available.names[i]
    }
  ] : []
  
  # No private subnets needed in this networking module
  private_subnets = []
  
  tags = merge(var.common_tags, {
    Purpose = "dr-networking-components"
    Service = "networking"
  })
}
