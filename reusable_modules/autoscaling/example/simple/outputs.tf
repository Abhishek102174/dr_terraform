# AutoScaling Module Outputs
output "asg_name" {
  description = "Name of the AutoScaling Group"
  value       = module.autoscaling.asg_name
}

output "asg_arn" {
  description = "ARN of the AutoScaling Group"
  value       = module.autoscaling.asg_arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = module.autoscaling.launch_template_id
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = module.autoscaling.launch_template_latest_version
}

# Individual Scaling Policy Outputs
output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = module.autoscaling.scale_up_policy_arn
}

output "scale_up_policy_name" {
  description = "Name of the scale up policy"
  value       = module.autoscaling.scale_up_policy_name
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = module.autoscaling.scale_down_policy_arn
}

output "scale_down_policy_name" {
  description = "Name of the scale down policy"
  value       = module.autoscaling.scale_down_policy_name
}

# All Scaling Policies (for backward compatibility)
output "all_scaling_policy_arns" {
  description = "Map of all scaling policy ARNs"
  value       = module.autoscaling.all_scaling_policy_arns
}

output "all_scaling_policy_names" {
  description = "Map of all scaling policy names"
  value       = module.autoscaling.all_scaling_policy_names
}

# Load Balancer Outputs
output "load_balancer_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.main.arn
}

output "load_balancer_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.main.dns_name
}

output "load_balancer_zone_id" {
  description = "Hosted zone ID of the Application Load Balancer"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = aws_lb_target_group.main.arn
}

# SNS Topic (if enabled)
output "sns_topic_arn" {
  description = "ARN of the SNS topic for AutoScaling notifications"
  value       = var.enable_sns_notifications ? aws_sns_topic.autoscaling_notifications[0].arn : null
}

# Notification Configuration
output "notification_configuration" {
  description = "AutoScaling notification configuration"
  value       = module.autoscaling.notification_configuration
}

# Application URL
output "application_url" {
  description = "URL to access the application"
  value       = "http://${aws_lb.main.dns_name}"
}
