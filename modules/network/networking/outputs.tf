# =============================================================================
# NETWORKING MODULE OUTPUTS - Using Reusable VPC Module
# =============================================================================

# Internet Gateway Outputs
output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = var.create_igw ? aws_internet_gateway.this[0].id : null
}

# NAT Gateway Outputs
output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.create_nat_gateways ? [for k, ngw in aws_nat_gateway.this : ngw.id] : []
}

output "nat_gateway_public_ips" {
  description = "List of NAT Gateway public IP addresses"
  value       = var.create_nat_gateways ? [for k, ngw in aws_nat_gateway.this : ngw.public_ip] : []
}

output "elastic_ip_ids" {
  description = "List of Elastic IP allocation IDs"
  value       = var.create_nat_gateways ? [for k, eip in aws_eip.nat : eip.id] : []
}

# Transit Gateway Outputs
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
  value       = var.create_tgw && length(var.tgw_subnet_ids) > 0 ? aws_ec2_transit_gateway_vpc_attachment.this[0].id : null
}

output "transit_gateway_route_table_id" {
  description = "ID of the Transit Gateway route table"
  value       = var.create_tgw_route_table ? aws_ec2_transit_gateway_route_table.this[0].id : null
}
