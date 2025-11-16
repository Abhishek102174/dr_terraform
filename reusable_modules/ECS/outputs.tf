output "cluster_id" {
  description = "ID of the ECS cluster"
  value       = local.cluster_id
}

output "cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = var.create_cluster ? aws_ecs_cluster.cluster[0].arn : var.existing_cluster_arn
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = var.create_cluster ? aws_ecs_cluster.cluster[0].name : split("/", var.existing_cluster_arn)[1]
}

output "service_id" {
  description = "The Amazon Resource Name (ARN) that identifies the service"
  value       = aws_ecs_service.service.id
}

output "service_name" {
  description = "The name of the service"
  value       = aws_ecs_service.service.name
}

output "service_cluster" {
  description = "The Amazon Resource Name (ARN) of cluster which the service runs on"
  value       = aws_ecs_service.service.cluster
}

output "task_definition_arn" {
  description = "Full ARN of the Task Definition"
  value       = aws_ecs_task_definition.task_definition.arn
}

output "task_definition_family" {
  description = "The family of the Task Definition"
  value       = aws_ecs_task_definition.task_definition.family
}

output "task_definition_revision" {
  description = "The revision of the task in a particular family"
  value       = aws_ecs_task_definition.task_definition.revision
}

output "execution_role_arn" {
  description = "The Amazon Resource Name (ARN) of the task execution role"
  value       = aws_iam_role.execution.arn
}

output "execution_role_name" {
  description = "The name of the task execution role"
  value       = aws_iam_role.execution.name
}

output "task_role_arn" {
  description = "The Amazon Resource Name (ARN) of the task role"
  value       = aws_iam_role.task.arn
}

output "task_role_name" {
  description = "The name of the task role"
  value       = aws_iam_role.task.name
}

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.log_group[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "The ARN of the CloudWatch log group"
  value       = var.enable_cloudwatch_logging ? aws_cloudwatch_log_group.log_group[0].arn : null
}

output "cpu_utilization_alarm_arn" {
  description = "The ARN of the CPU utilization CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_utilization[0].arn : null
}

output "memory_utilization_alarm_arn" {
  description = "The ARN of the memory utilization CloudWatch alarm"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.memory_utilization[0].arn : null
}

output "autoscaling_target_arn" {
  description = "The ARN of the autoscaling target"
  value       = var.enable_autoscaling ? aws_appautoscaling_target.autoscaling_target[0].arn : null
}

output "autoscaling_policy_arn" {
  description = "The ARN of the autoscaling policy"
  value       = var.enable_autoscaling ? aws_appautoscaling_policy.autoscaling_policy[0].arn : null
}

output "dashboard_url" {
  description = "The URL of the CloudWatch dashboard"
  value       = var.enable_cloudwatch_alarms ? "https://${var.region}.console.aws.amazon.com/cloudwatch/home?region=${var.region}#dashboards:name=${aws_cloudwatch_dashboard.dashboard[0].dashboard_name}" : null
}
