output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.this.id
}

output "security_group_arn" {
  description = "ARN of the security group"
  value       = aws_security_group.this.arn
}

output "security_group_name" {
  description = "Name of the security group"
  value       = aws_security_group.this.name
}

output "security_group_description" {
  description = "Description of the security group"
  value       = aws_security_group.this.description
}

output "security_group_vpc_id" {
  description = "VPC ID of the security group"
  value       = aws_security_group.this.vpc_id
}

output "ingress_rules" {
  description = "Ingress rules of the security group"
  value       = var.ingress_rules
}

output "egress_rules" {
  description = "Egress rules of the security group"
  value       = var.egress_rules
}