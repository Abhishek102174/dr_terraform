output "web_security_group_id" {
  description = "ID of the web server security group"
  value       = module.web_security_group.security_group_id
}

output "web_security_group_arn" {
  description = "ARN of the web server security group"
  value       = module.web_security_group.security_group_arn
}

output "database_security_group_id" {
  description = "ID of the database security group"
  value       = module.database_security_group.security_group_id
}

output "database_security_group_arn" {
  description = "ARN of the database security group"
  value       = module.database_security_group.security_group_arn
}