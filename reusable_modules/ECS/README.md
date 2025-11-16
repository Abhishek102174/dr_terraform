# Detailed ECS Terraform Module

This module provisions an **Amazon ECS (Elastic Container Service)** cluster with enhanced configuration including Fargate and EC2 launch types, CloudWatch monitoring, logging, alarms, and dashboards.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Used](#resources-used)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module supports:
- ECS Cluster creation with Container Insights
- Task Definition with Fargate or EC2 launch types
- ECS Service with configurable scaling and networking
- CloudWatch logging integration
- Health checks configuration
- CloudWatch alarms for monitoring (CPU, Memory, Task Count)
- CloudWatch Dashboard for visualization
- IAM roles and policies for execution and task roles
- Support for both REPLICA and DAEMON scheduling strategies
- Capacity provider strategies

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider version 5.40.0 or higher
- AWS CLI configured with proper permissions
- IAM permissions for ECS, CloudWatch, IAM, and VPC resources
- VPC with subnets and security groups (for Fargate launch type)

---

## Usage Example

```hcl
module "ecs_service" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/ECS?ref=v2.0.0"

  name = "my-web-app"
  tags = {
    Environment = "production"
    Project     = "web-services"
  }

  # Cluster Configuration
  container_insights_enabled = true

  # Task Definition Configuration
  launch_type = "FARGATE"
  fargate_cpu = "256"
  fargate_memory = "512"
  container_definitions = jsonencode([
    {
      name      = "web-app"
      image     = "nginx:latest"
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

  # Service Configuration
  desired_count = 2
  is_daemon = false

  # Network Configuration (for Fargate)
  subnets = ["subnet-12345678", "subnet-87654321"]
  security_groups = ["sg-12345678"]
  assign_public_ip = true

  # Health Checks
  enable_health_checks = true
  health_check_grace_period_seconds = 300
  health_check_config = {
    command     = ["CMD-SHELL", "curl -f http://localhost/ || exit 1"]
    interval    = 30
    timeout     = 5
    retries     = 3
    start_period = 60
  }

  # CloudWatch Logging
  enable_cloudwatch_logging = true
  log_retention_in_days = 14
  region = "us-west-2"

  # CloudWatch Alarms
  enable_cloudwatch_alarms = true
  cpu_utilization_threshold = 80
  memory_utilization_threshold = 80
  alarm_notification_topic_arn = "arn:aws:sns:us-west-2:123456789012:alerts"

  # Dashboard Configuration
  dashboard_cpu_memory_widget_x = 0
  dashboard_cpu_memory_widget_y = 0
  dashboard_task_count_widget_x = 12
  dashboard_task_count_widget_y = 0
  dashboard_widget_width = 12
  dashboard_widget_height = 6
}
```

## Module Structure

```
modules
└── ECS
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── iam.tf
  ├── versions.tf
  └── README.md
  └── examples
    └── fargate
      ├── main.tf
      ├── variables.tf
      ├── versions.tf
      └── README.md
```

---

## Resources Used

| Resource                              | Purpose                                   |
|---------------------------------------|-------------------------------------------|
| `aws_ecs_cluster`                     | Creates the ECS cluster                   |
| `aws_ecs_task_definition`             | Defines container tasks                   |
| `aws_ecs_service`                     | Manages running tasks                     |
| `aws_cloudwatch_log_group`            | Stores container logs                     |
| `aws_cloudwatch_metric_alarm`         | Monitors service metrics                  |
| `aws_cloudwatch_dashboard`            | Visualizes service metrics                |
| `aws_iam_role` (execution)            | ECS task execution permissions            |
| `aws_iam_role` (task)                 | Application-level permissions             |

---

## Input Variables

| Name                                  | Type    | Description                                                    | Required |
|---------------------------------------|---------|----------------------------------------------------------------|----------|
| `name`                               | string  | Name prefix for ECS resources                                   | Yes      |
| `tags`                               | map     | Tags to apply to all resources                                  | Yes      |
| `container_insights_enabled`         | bool    | Enable CloudWatch Container Insights                            | Yes      |
| `container_definitions`              | string  | JSON string of container definitions                            | Yes      |
| `launch_type`                        | string  | Launch type: FARGATE or EC2                                     | Yes      |
| `fargate_cpu`                        | string  | CPU units for Fargate tasks                                     | No       |
| `fargate_memory`                     | string  | Memory (MB) for Fargate tasks                                   | No       |
| `desired_count`                      | number  | Number of desired tasks                                         | Yes      |
| `is_daemon`                          | bool    | Use DAEMON scheduling strategy                                  | Yes      |
| `subnets`                            | list    | Subnet IDs for Fargate tasks                                    | No       |
| `security_groups`                    | list    | Security group IDs for Fargate tasks                            | No       |
| `assign_public_ip`                   | bool    | Assign public IP to Fargate tasks                               | No       |
| `capacity_provider`                  | string  | Capacity provider name                                          | No       |
| `capacity_provider_weight`           | number  | Weight for capacity provider strategy                           | No       |
| `enable_health_checks`               | bool    | Enable container health checks                                  | Yes      |
| `health_check_grace_period_seconds`  | number  | Grace period before health checks start                         | No       |
| `health_check_config`                | object  | Health check configuration                                      | No       |
| `enable_cloudwatch_logging`          | bool    | Enable CloudWatch logging                                       | Yes      |
| `log_retention_in_days`              | number  | Log retention period in days                                    | No       |
| `region`                             | string  | AWS region for CloudWatch logs                                  | No       |
| `enable_cloudwatch_alarms`           | bool    | Enable CloudWatch alarms                                        | Yes      |
| `cpu_utilization_threshold`          | number  | CPU utilization alarm threshold                                 | No       |
| `memory_utilization_threshold`       | number  | Memory utilization alarm threshold                              | No       |
| `unhealthy_tasks_threshold`          | number  | Unhealthy tasks alarm threshold                                 | No       |
| `alarm_evaluation_periods`           | number  | Number of evaluation periods for alarms                         | No       |
| `alarm_period`                       | number  | Period in seconds for alarms                                    | No       |
| `alarm_statistic`                    | string  | Statistic for alarm evaluation                                  | No       |
| `alarm_notification_topic_arn`       | string  | SNS topic ARN for alarm notifications                           | No       |
| `running_tasks_alarm_period`         | number  | Period for running tasks alarm                                  | No       |
| `dashboard_cpu_memory_widget_x`      | number  | X position for CPU/Memory widget                                | No       |
| `dashboard_cpu_memory_widget_y`      | number  | Y position for CPU/Memory widget                                | No       |
| `dashboard_task_count_widget_x`      | number  | X position for Task Count widget                                | No       |
| `dashboard_task_count_widget_y`      | number  | Y position for Task Count widget                                | No       |
| `dashboard_widget_width`             | number  | Width of dashboard widgets                                      | No       |
| `dashboard_widget_height`            | number  | Height of dashboard widgets                                     | No       |
| `dashboard_metric_period`            | number  | Metric period for dashboard                                     | No       |

---

## Outputs

| Name                           | Description                                                      |
|--------------------------------|------------------------------------------------------------------|
| `cluster_id`                   | The ID of the ECS cluster                                        |
| `cluster_arn`                  | The ARN of the ECS cluster                                       |
| `cluster_name`                 | The name of the ECS cluster                                      |
| `service_id`                   | The ID of the ECS service                                        |
| `service_arn`                  | The ARN of the ECS service                                       |
| `service_name`                 | The name of the ECS service                                      |
| `task_definition_arn`          | The ARN of the task definition                                   |
| `task_definition_family`       | The family of the task definition                                |
| `task_definition_revision`     | The revision of the task definition                              |
| `log_group_name`               | The name of the CloudWatch log group (if enabled)               |
| `log_group_arn`                | The ARN of the CloudWatch log group (if enabled)                |
| `execution_role_arn`           | The ARN of the task execution role                               |
| `task_role_arn`                | The ARN of the task role                                         |
| `dashboard_url`                | The URL of the CloudWatch dashboard (if enabled)                |

---

## Best Practices

- Use **Fargate** launch type for serverless container management and simplified operations.
- Enable **Container Insights** for enhanced monitoring and troubleshooting capabilities.
- Configure **health checks** to ensure application availability and automatic recovery.
- Set appropriate **CPU and memory** limits based on application requirements.
- Use **CloudWatch alarms** to proactively monitor service health and performance.
- Enable **logging** to CloudWatch for centralized log management and debugging.
- Set **log retention periods** to balance cost and compliance requirements.
- Use **private subnets** for Fargate tasks when possible for better security.
- Configure **security groups** with minimal required permissions.
- Use **capacity providers** for cost optimization with mixed instance types.
- Set `desired_count` to at least 2 for high availability in production.
- Monitor **task failure patterns** and adjust health check parameters accordingly.
- Use **DAEMON** scheduling strategy only when you need exactly one task per container instance.

---
