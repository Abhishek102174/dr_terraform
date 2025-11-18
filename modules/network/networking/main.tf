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

# Internet Gateway attached to existing VPC
resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = var.vpc_id

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-igw"
    Service = "networking"
    Purpose = "dr-internet-gateway"
  })
}

# NAT Gateways in provided public subnets
resource "aws_eip" "nat" {
  for_each = var.create_nat_gateways && length(var.public_subnet_ids) > 0 ? { for idx, sid in var.public_subnet_ids : idx => sid } : {}
  domain   = "vpc"

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-nat-eip-${each.key}"
    Service = "networking"
    Purpose = "dr-nat-eip"
  })
}

resource "aws_nat_gateway" "this" {
  for_each     = var.create_nat_gateways && length(var.public_subnet_ids) > 0 ? { for idx, sid in var.public_subnet_ids : idx => sid } : {}
  subnet_id    = each.value
  allocation_id = aws_eip.nat[each.key].id

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-nat-${each.key}"
    Service = "networking"
    Purpose = "dr-nat-gateway"
  })
}

# Transit Gateway for existing VPC
resource "aws_ec2_transit_gateway" "this" {
  count                           = var.create_tgw ? 1 : 0
  description                     = var.tgw_description
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation
  amazon_side_asn                 = var.tgw_amazon_side_asn

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-tgw"
    Service = "networking"
    Purpose = "dr-transit-gateway"
  })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count              = var.create_tgw && length(var.tgw_subnet_ids) > 0 ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  vpc_id             = var.vpc_id
  subnet_ids         = var.tgw_subnet_ids

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-tgw-attachment"
    Service = "networking"
    Purpose = "dr-tgw-attachment"
  })
}

resource "aws_ec2_transit_gateway_route_table" "this" {
  count              = var.create_tgw_route_table ? 1 : 0
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-tgw-rt"
    Service = "networking"
    Purpose = "dr-tgw-route-table"
  })
}
