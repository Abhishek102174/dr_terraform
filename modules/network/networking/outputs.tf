# =============================================================================
# NETWORKING MODULE OUTPUTS - Using Reusable VPC Module
# =============================================================================

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_igw ? module.networking_components.internet_gateway_id : null
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.create_nat_gateways ? module.networking_components.nat_gateway_ids : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = var.create_nat_gateways ? [for nat in module.networking_components.nat_gateway_ids : ""] : []  # VPC module doesn't expose public IPs directly
}

output "elastic_ip_ids" {
  description = "List of Elastic IP allocation IDs"
  value       = var.create_nat_gateways ? [] : []  # VPC module doesn't expose EIP IDs directly
}

# Transit Gateway Outputs
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = var.create_tgw ? module.networking_components.transit_gateway_id : null
}

output "transit_gateway_arn" {
  description = "ARN of the Transit Gateway"
  value       = var.create_tgw ? module.networking_components.transit_gateway_arn : null
}

output "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway VPC attachment"
  value       = var.create_tgw ? module.networking_components.transit_gateway_attachment_id : null
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = var.create_tgw_route_table ? module.networking_components.transit_gateway_route_table_id : null
}
