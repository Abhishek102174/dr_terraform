# VPC
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-igw"
    }
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  for_each = { for idx, subnet in var.public_subnets : idx => subnet }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = each.value.availability_zone
  map_public_ip_on_launch = true

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-${each.key}"
      Type = "Public"
    }
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  for_each = { for idx, subnet in var.private_subnets : idx => subnet }

  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-${each.key}"
      Type = "Private"
    }
  )
}

# NAT Gateway
resource "aws_eip" "nat" {
  for_each = var.create_nat_gateway ? { for idx, subnet in var.public_subnets : idx => subnet } : {}
  domain   = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-eip-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  for_each = var.create_nat_gateway ? { for idx, subnet in var.public_subnets : idx => subnet } : {}

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-nat-${each.key}"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

# Route Tables
resource "aws_route_table" "public" {
  count  = var.create_igw ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-public-rt"
    }
  )
}

resource "aws_route_table" "private" {
  for_each = var.create_nat_gateway ? { for idx, subnet in var.private_subnets : idx => subnet } : {}
  vpc_id   = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this[each.key].id
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-private-rt-${each.key}"
    }
  )
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  for_each = var.create_igw ? { for idx, subnet in var.public_subnets : idx => subnet } : {}

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_route_table_association" "private" {
  for_each = var.create_nat_gateway ? { for idx, subnet in var.private_subnets : idx => subnet } : {}

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# DHCP Options Set
resource "aws_vpc_dhcp_options" "this" {
  count = var.create_dhcp_options ? 1 : 0

  domain_name         = var.dhcp_options_domain_name
  domain_name_servers = var.dhcp_options_domain_name_servers

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-dhcp-options"
    }
  )
}

resource "aws_vpc_dhcp_options_association" "this" {
  count = var.create_dhcp_options ? 1 : 0

  vpc_id          = aws_vpc.this.id
  dhcp_options_id = aws_vpc_dhcp_options.this[0].id
}

# Transit Gateway
resource "aws_ec2_transit_gateway" "this" {
  count = var.create_tgw ? 1 : 0

  description                     = var.tgw_description
  default_route_table_association = var.tgw_default_route_table_association
  default_route_table_propagation = var.tgw_default_route_table_propagation

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw"
    }
  )
}

# Transit Gateway VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {
  count = var.create_tgw ? 1 : 0

  subnet_ids         = var.tgw_subnet_ids != null ? var.tgw_subnet_ids : [for subnet in aws_subnet.private : subnet.id]
  transit_gateway_id = aws_ec2_transit_gateway.this[0].id
  vpc_id             = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw-attachment"
    }
  )
}

# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "this" {
  count = var.create_tgw_route_table ? 1 : 0

  transit_gateway_id = aws_ec2_transit_gateway.this[0].id

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-tgw-rt"
    }
  )
}

# Security Group for VPC Endpoints
resource "aws_security_group" "vpc_endpoints" {
  count = length(var.vpc_endpoints_interface) > 0 ? 1 : 0
  
  name_prefix = "${var.name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = var.vpc_endpoints_sg_ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = length(ingress.value.cidr_blocks) > 0 ? ingress.value.cidr_blocks : [var.cidr_block]
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = var.vpc_endpoints_sg_egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-vpc-endpoints-sg"
    }
  )
}

# VPC Endpoints
resource "aws_vpc_endpoint" "gateway" {
  for_each = var.vpc_endpoints_gateway

  vpc_id            = aws_vpc.this.id
  service_name      = each.value.service_name
  vpc_endpoint_type = "Gateway"
  route_table_ids   = each.value.route_table_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}-endpoint"
    }
  )
}

resource "aws_vpc_endpoint" "interface" {
  for_each = var.vpc_endpoints_interface

  vpc_id              = aws_vpc.this.id
  service_name        = each.value.service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = each.value.subnet_ids
  security_group_ids  = length(each.value.security_group_ids) > 0 ? each.value.security_group_ids : [aws_security_group.vpc_endpoints[0].id]
  private_dns_enabled = each.value.private_dns_enabled

  tags = merge(
    var.tags,
    {
      Name = "${var.name}-${each.key}-endpoint"
    }
  )
}