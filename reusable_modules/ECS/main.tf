# Create cluster only if create_cluster is true
resource "aws_ecs_cluster" "cluster" {
  count = var.create_cluster ? 1 : 0
  name  = var.cluster_name != null ? var.cluster_name : "${var.name}"
  
  setting {
    name  = "containerInsights"
    value = var.container_insights_enabled ? "enabled" : "disabled"
  }
  tags = var.tags
}

# Local to determine which cluster to use
locals {
  cluster_id   = var.create_cluster ? aws_ecs_cluster.cluster[0].id : var.existing_cluster_arn
  cluster_name = var.create_cluster ? aws_ecs_cluster.cluster[0].name : split("/", var.existing_cluster_arn)[1]
}

# Task definition with conditional logging
locals {
  container_definitions_json = jsondecode(var.container_definitions)
  
  container_definitions_final = jsonencode([
    merge(
      local.container_definitions_json[0],
      var.enable_cloudwatch_logging ? {
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            "awslogs-group"         = aws_cloudwatch_log_group.log_group[0].name
            "awslogs-region"        = var.region
            "awslogs-stream-prefix" = "ecs/${var.name}/logs"
          }
        }
      } : {},
      var.enable_health_checks ? {
        healthCheck = {
          command     = var.health_check_config.command
          interval    = var.health_check_config.interval
          timeout     = var.health_check_config.timeout
          retries     = var.health_check_config.retries
          startPeriod = var.health_check_config.start_period
        }
      } : {}
    )
  ])
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "${var.name}"
  container_definitions    = local.container_definitions_final
  requires_compatibilities = [var.launch_type]
  network_mode             = var.launch_type == "FARGATE" ? "awsvpc" : "bridge"
  cpu                      = var.launch_type == "FARGATE" ? var.fargate_cpu : null
  memory                   = var.launch_type == "FARGATE" ? var.fargate_memory : null
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn
  tags                     = var.tags

  depends_on = [aws_cloudwatch_log_group.log_group]
}

resource "aws_ecs_service" "service" {
  name                = "${var.name}"
  cluster             = local.cluster_id
  task_definition     = aws_ecs_task_definition.task_definition.arn
  desired_count       = var.desired_count
  launch_type         = var.launch_type
  scheduling_strategy = var.is_daemon ? "DAEMON" : "REPLICA"

  # Enable service discovery for health checks
  health_check_grace_period_seconds = var.enable_health_checks ? var.health_check_grace_period_seconds : null

  dynamic "network_configuration" {
    for_each = var.launch_type == "FARGATE" ? [1] : []
    content {
      subnets          = var.subnets
      security_groups  = var.security_groups
      assign_public_ip = var.assign_public_ip
    }
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider != null ? [1] : []
    content {
      capacity_provider = var.capacity_provider
      weight            = var.capacity_provider_weight
    }
  }

  tags = var.tags

  depends_on = [aws_cloudwatch_log_group.log_group]
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "log_group" {
  count             = var.enable_cloudwatch_logging ? 1 : 0
  name              = "/ecs/${var.name}"
  retention_in_days = var.log_retention_in_days
  tags              = var.tags
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.cpu_utilization_threshold
  alarm_description   = "This metric monitors ECS service CPU utilization"
  alarm_actions       = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []
  ok_actions          = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.service.name
    ClusterName = local.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.memory_utilization_threshold
  alarm_description   = "This metric monitors ECS service memory utilization"
  alarm_actions       = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []
  ok_actions          = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.service.name
    ClusterName = local.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "service_running_tasks" {
  count               = var.enable_cloudwatch_alarms ? 1 : 0
  alarm_name          = "${var.name}"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "RunningTaskCount"
  namespace           = "AWS/ECS"
  period              = var.running_tasks_alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.desired_count
  alarm_description   = "This metric monitors ECS service running task count"
  alarm_actions       = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []
  ok_actions          = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.service.name
    ClusterName = local.cluster_name
  }

  tags = var.tags
}

resource "aws_cloudwatch_metric_alarm" "service_unhealthy_tasks" {
  count               = var.enable_cloudwatch_alarms && var.enable_health_checks ? 1 : 0
  alarm_name          = "${var.name}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "UnhealthyTaskCount"
  namespace           = "AWS/ECS"
  period              = var.running_tasks_alarm_period
  statistic           = var.alarm_statistic
  threshold           = var.unhealthy_tasks_threshold
  alarm_description   = "This metric monitors ECS service unhealthy task count"
  alarm_actions       = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []
  ok_actions          = var.alarm_notification_topic_arn != "" ? [var.alarm_notification_topic_arn] : []

  dimensions = {
    ServiceName = aws_ecs_service.service.name
    ClusterName = local.cluster_name
  }

  tags = var.tags
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "dashboard" {
  count          = var.enable_cloudwatch_alarms ? 1 : 0
  dashboard_name = "${var.name}"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = var.dashboard_cpu_memory_widget_x
        y      = var.dashboard_cpu_memory_widget_y
        width  = var.dashboard_widget_width
        height = var.dashboard_widget_height

        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ServiceName", aws_ecs_service.service.name, "ClusterName", local.cluster_name],
            [".", "MemoryUtilization", ".", ".", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "ECS Service CPU and Memory Utilization"
          period  = var.dashboard_metric_period
        }
      },
      {
        type   = "metric"
        x      = var.dashboard_task_count_widget_x
        y      = var.dashboard_task_count_widget_y
        width  = var.dashboard_widget_width
        height = var.dashboard_widget_height

        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ServiceName", aws_ecs_service.service.name, "ClusterName", local.cluster_name],
            [".", "DesiredCount", ".", ".", ".", "."],
          ]
          view    = "timeSeries"
          stacked = false
          region  = var.region
          title   = "ECS Service Task Count"
          period  = var.dashboard_metric_period
        }
      }
    ]
  })
}
