output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = aws_vpc.this.arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_igw ? aws_internet_gateway.this[0].id : null
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = [for subnet in aws_subnet.public : subnet.id]
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = [for subnet in aws_subnet.private : subnet.id]
}

output "public_subnets" {
  description = "Public subnet details"
  value = {
    for k, subnet in aws_subnet.public : k => {
      id                = subnet.id
      arn               = subnet.arn
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "private_subnets" {
  description = "Private subnet details"
  value = {
    for k, subnet in aws_subnet.private : k => {
      id                = subnet.id
      arn               = subnet.arn
      cidr_block        = subnet.cidr_block
      availability_zone = subnet.availability_zone
    }
  }
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = [for nat in aws_nat_gateway.this : nat.id]
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = var.create_igw ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = [for rt in aws_route_table.private : rt.id]
}

# DHCP Options outputs
output "dhcp_options_id" {
  description = "ID of the DHCP options set"
  value       = var.create_dhcp_options ? aws_vpc_dhcp_options.this[0].id : null
}

# Transit Gateway outputs
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = var.create_tgw ? aws_ec2_transit_gateway.this[0].id : null
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = var.create_tgw ? aws_ec2_transit_gateway.this[0].arn : null
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = var.create_tgw ? aws_ec2_transit_gateway_vpc_attachment.this[0].id : null
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = var.create_tgw_route_table ? aws_ec2_transit_gateway_route_table.this[0].id : null
}

# VPC Endpoints outputs
output "vpc_endpoint_gateway_ids" {
  description = "IDs of the Gateway VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.gateway : k => v.id }
}

output "vpc_endpoint_interface_ids" {
  description = "IDs of the Interface VPC endpoints"
  value       = { for k, v in aws_vpc_endpoint.interface : k => v.id }
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the default VPC endpoints security group"
  value       = length(aws_security_group.vpc_endpoints) > 0 ? aws_security_group.vpc_endpoints[0].id : null
}