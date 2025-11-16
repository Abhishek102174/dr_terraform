output "arn" {
  description = "Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "dns_name" {
  description = "Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "zone_id" {
  description = "Route53 zone ID"
  value       = aws_lb.main.zone_id
}

output "sg_id" {
  description = "Security Group ID (ALB only)"
  value       = try(aws_security_group.lb_sg[0].id, null)
}

output "listener_arns" {
  description = "Map of listener ARNs"
  value       = { for k, v in aws_lb_listener.main : k => v.arn }
}

output "listener_rule_arns" {
  description = "Map of listener rule ARNs"
  value       = { for k, v in aws_lb_listener_rule.main : k => v.arn }
}

output "target_group_arns" {
  description = "Map of target group ARNs"
  value       = { for k, v in aws_lb_target_group.main : k => v.arn }
}

output "target_group_names" {
  description = "Map of target group names"
  value       = { for k, v in aws_lb_target_group.main : k => v.name }
}
