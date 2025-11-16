# Core VPC Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_arn" {
  description = "ARN of the VPC"
  value       = module.vpc.vpc_arn
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

# Subnet Outputs
output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnet_ids
}

output "public_subnets" {
  description = "Detailed public subnet information"
  value       = module.vpc.public_subnets
}

output "private_subnets" {
  description = "Detailed private subnet information"
  value       = module.vpc.private_subnets
}

# Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

# Route Table Outputs
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = module.vpc.public_route_table_id
}

output "private_route_table_ids" {
  description = "IDs of the private route tables"
  value       = module.vpc.private_route_table_ids
}

# DHCP Options Output
output "dhcp_options_id" {
  description = "ID of the DHCP options set"
  value       = module.vpc.dhcp_options_id
}

# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = module.vpc.transit_gateway_id
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = module.vpc.transit_gateway_arn
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = module.vpc.transit_gateway_attachment_id
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = module.vpc.transit_gateway_route_table_id
}

# VPC Endpoints Outputs
output "vpc_endpoint_gateway_ids" {
  description = "IDs of the Gateway VPC endpoints"
  value       = module.vpc.vpc_endpoint_gateway_ids
}

output "vpc_endpoint_interface_ids" {
  description = "IDs of the Interface VPC endpoints"
  value       = module.vpc.vpc_endpoint_interface_ids
}

output "vpc_endpoints_security_group_id" {
  description = "ID of the VPC endpoints security group"
  value       = module.vpc.vpc_endpoints_security_group_id
}

# Summary Output
output "vpc_summary" {
  description = "Summary of VPC resources created"
  value = {
    vpc_id                    = module.vpc.vpc_id
    public_subnets_count      = length(module.vpc.public_subnet_ids)
    private_subnets_count     = length(module.vpc.private_subnet_ids)
    nat_gateways_count        = length(module.vpc.nat_gateway_ids)
    dhcp_options_enabled      = var.create_dhcp_options
    transit_gateway_enabled   = var.create_tgw
    vpc_endpoints_enabled     = var.enable_vpc_endpoints
    gateway_endpoints_count   = var.enable_vpc_endpoints ? length(module.vpc.vpc_endpoint_gateway_ids) : 0
    interface_endpoints_count = var.enable_vpc_endpoints ? length(module.vpc.vpc_endpoint_interface_ids) : 0
  }
}