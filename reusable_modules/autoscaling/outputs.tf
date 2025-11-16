output "asg_name" {
  description = "Name of the AutoScaling Group"
  value       = aws_autoscaling_group.main.name
}

output "asg_arn" {
  description = "ARN of the AutoScaling Group"
  value       = aws_autoscaling_group.main.arn
}

output "launch_template_id" {
  description = "ID of the Launch Template"
  value       = aws_launch_template.main.id
}

output "launch_template_latest_version" {
  description = "Latest version of the Launch Template"
  value       = aws_launch_template.main.latest_version
}

output "scale_up_policy_arn" {
  description = "ARN of the scale up policy"
  value       = var.enable_scale_up_policy ? aws_autoscaling_policy.scale_up[0].arn : null
}

output "scale_up_policy_name" {
  description = "Name of the scale up policy"
  value       = var.enable_scale_up_policy ? aws_autoscaling_policy.scale_up[0].name : null
}

output "scale_down_policy_arn" {
  description = "ARN of the scale down policy"
  value       = var.enable_scale_down_policy ? aws_autoscaling_policy.scale_down[0].arn : null
}

output "scale_down_policy_name" {
  description = "Name of the scale down policy"
  value       = var.enable_scale_down_policy ? aws_autoscaling_policy.scale_down[0].name : null
}

output "notification_configuration" {
  description = "AutoScaling notification configuration"
  value = var.enable_notifications && var.notification_topic_arn != "" ? {
    topic_arn = var.notification_topic_arn
    types     = var.notification_types
  } : null
}

output "all_scaling_policy_arns" {
  description = "Map of all scaling policy ARNs"
  value = {
    scale_up   = var.enable_scale_up_policy ? aws_autoscaling_policy.scale_up[0].arn : null
    scale_down = var.enable_scale_down_policy ? aws_autoscaling_policy.scale_down[0].arn : null
  }
}

output "all_scaling_policy_names" {
  description = "Map of all scaling policy names"
  value = {
    scale_up   = var.enable_scale_up_policy ? aws_autoscaling_policy.scale_up[0].name : null
    scale_down = var.enable_scale_down_policy ? aws_autoscaling_policy.scale_down[0].name : null
  }
}
