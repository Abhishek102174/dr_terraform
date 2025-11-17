# VPC Module Outputs - DR Network Information

output "vpc_id" {
  description = "ID of the DR VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "CIDR block of the DR VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_arn" {
  description = "ARN of the DR VPC"
  value       = module.vpc.vpc_arn
}

output "cidr_block" {
  description = "CIDR block of the DR VPC (alias for compatibility)"
  value       = module.vpc.vpc_cidr_block
}

data "aws_vpc" "this" {
  id = module.vpc.vpc_id
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

output "default_security_group_id" {
  description = "ID of the default security group for the DR VPC"
  value       = data.aws_security_group.default.id
}

output "vpc_main_route_table_id" {
  description = "ID of the main route table associated with the DR VPC"
  value       = data.aws_vpc.this.main_route_table_id
}
