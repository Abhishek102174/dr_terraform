variable "region" {
  description = "AWS region"
  type        = string
}

variable "cluster_name" {
  description = "Name of existing ECS cluster to use, or name for new cluster if create_cluster is true"
  type        = string
  default     = null
}

variable "create_cluster" {
  description = "Whether to create a new ECS cluster or use an existing one"
  type        = bool
  default     = true
}

variable "existing_cluster_arn" {
  description = "ARN of existing ECS cluster to use (when create_cluster is false)"
  type        = string
  default     = null
}


variable "name" {
  description = "Base name for all resources"
  type        = string
}

variable "launch_type" {
  description = "Launch type (EC2 or FARGATE)"
  type        = string
  default     = "EC2"
}

variable "is_daemon" {
  description = "Daemon service type"
  type        = bool
  default     = false
}

variable "container_definitions" {
  description = "Container definitions JSON"
  type        = string
}

variable "desired_count" {
  description = "Initial task count"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "enable_autoscaling" {
  description = "Enable service autoscaling"
  type        = bool
  default     = false
}

variable "autoscaling_config" {
  description = "Autoscaling configuration"
  type = object({
    min_capacity = number
    max_capacity = number
    target_value = number
  })
  default = null
}

variable "capacity_provider" {
  description = "Capacity provider for EC2 clusters"
  type        = string
  default     = null
}

variable "subnets" {
  description = "List of subnet IDs for Fargate services"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  description = "List of security group IDs for Fargate services"
  type        = list(string)
  default     = []
}

variable "assign_public_ip" {
  description = "Whether to assign a public IP address to Fargate tasks"
  type        = bool
  default     = false
}

variable "enable_cloudwatch_logging" {
  description = "Enable CloudWatch logging for containers"
  type        = bool
  default     = true
}

variable "log_retention_in_days" {
  description = "CloudWatch log group retention period in days"
  type        = number
  default     = 30
}

variable "enable_health_checks" {
  description = "Enable container health checks"
  type        = bool
  default     = true
}

variable "health_check_config" {
  description = "Health check configuration"
  type = object({
    command      = list(string)
    interval     = number
    timeout      = number
    retries      = number
    start_period = number
  })
  default = {
    command      = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
    interval     = 30
    timeout      = 5
    retries      = 3
    start_period = 60
  }
}

variable "enable_cloudwatch_alarms" {
  description = "Enable CloudWatch alarms"
  type        = bool
  default     = true
}

variable "alarm_notification_topic_arn" {
  description = "SNS topic ARN for alarm notifications"
  type        = string
  default     = ""
}

variable "cpu_utilization_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "memory_utilization_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "container_insights_enabled" {
  description = "Whether to enable container insights for the ECS cluster"
  type        = bool
  default     = true
}

variable "fargate_cpu" {
  description = "CPU units for Fargate tasks"
  type        = string
  default     = "256"
}

variable "fargate_memory" {
  description = "Memory for Fargate tasks"
  type        = string
  default     = "512"
}

variable "health_check_grace_period_seconds" {
  description = "Grace period in seconds for health checks"
  type        = number
  default     = 300
}

variable "capacity_provider_weight" {
  description = "Weight for the capacity provider strategy"
  type        = number
  default     = 100
}

variable "alarm_evaluation_periods" {
  description = "Number of evaluation periods for CloudWatch alarms"
  type        = string
  default     = "2"
}

variable "alarm_period" {
  description = "Period in seconds for CloudWatch alarms"
  type        = string
  default     = "120"
}

variable "alarm_statistic" {
  description = "Statistic for CloudWatch alarms"
  type        = string
  default     = "Average"
}

variable "running_tasks_alarm_period" {
  description = "Period in seconds for running tasks alarm"
  type        = string
  default     = "60"
}

variable "unhealthy_tasks_threshold" {
  description = "Threshold for unhealthy tasks alarm"
  type        = number
  default     = 0
}

variable "dashboard_cpu_memory_widget_x" {
  description = "X position for CPU/Memory widget on dashboard"
  type        = number
  default     = 0
}

variable "dashboard_cpu_memory_widget_y" {
  description = "Y position for CPU/Memory widget on dashboard"
  type        = number
  default     = 0
}

variable "dashboard_task_count_widget_x" {
  description = "X position for Task Count widget on dashboard"
  type        = number
  default     = 0
}

variable "dashboard_task_count_widget_y" {
  description = "Y position for Task Count widget on dashboard"
  type        = number
  default     = 6
}

variable "dashboard_widget_width" {
  description = "Width for dashboard widgets"
  type        = number
  default     = 12
}

variable "dashboard_widget_height" {
  description = "Height for dashboard widgets"
  type        = number
  default     = 6
}

variable "dashboard_metric_period" {
  description = "Period for dashboard metrics"
  type        = number
  default     = 300
}

# Autoscaling variables
variable "autoscaling_policy_type" {
  description = "The policy type for autoscaling (e.g., 'TargetTrackingScaling', 'StepScaling')"
  type        = string
  default     = "TargetTrackingScaling"

  validation {
    condition = contains(["TargetTrackingScaling", "StepScaling"], var.autoscaling_policy_type)
    error_message = "The autoscaling_policy_type must be either 'TargetTrackingScaling' or 'StepScaling'."
  }
}

variable "autoscaling_scale_in_cooldown" {
  description = "The amount of time, in seconds, after a scale in activity completes before another scale in activity can start"
  type        = number
  default     = 300

  validation {
    condition     = var.autoscaling_scale_in_cooldown >= 60
    error_message = "The autoscaling_scale_in_cooldown must be at least 60 seconds."
  }
}

variable "autoscaling_scale_out_cooldown" {
  description = "The amount of time, in seconds, after a scale out activity completes before another scale out activity can start"
  type        = number
  default     = 300

  validation {
    condition     = var.autoscaling_scale_out_cooldown >= 60
    error_message = "The autoscaling_scale_out_cooldown must be at least 60 seconds."
  }
}

variable "autoscaling_metric_type" {
  description = "The metric type for autoscaling (e.g., 'ECSServiceAverageCPUUtilization', 'ECSServiceAverageMemoryUtilization')"
  type        = string
  default     = "ECSServiceAverageCPUUtilization"

  validation {
    condition = contains([
      "ECSServiceAverageCPUUtilization", 
      "ECSServiceAverageMemoryUtilization",
      "ALBRequestCountPerTarget"
    ], var.autoscaling_metric_type)
    error_message = "The autoscaling_metric_type must be one of: ECSServiceAverageCPUUtilization, ECSServiceAverageMemoryUtilization, ALBRequestCountPerTarget."
  }
}
