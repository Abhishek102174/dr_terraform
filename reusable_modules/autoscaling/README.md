# Detailed Auto Scaling Group Terraform Module

This module provisions an **Amazon EC2 Auto Scaling Group** with enhanced configuration including launch templates, scaling policies, notifications, and comprehensive instance management capabilities.

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
- Launch template configuration with custom AMI, instance type, and user data
- Auto Scaling Group with configurable min/max/desired capacity
- Security group integration
- Health check configuration for EC2 instances and automatically scaling based unhealthy instances
- IAM instance profile attachment
- Custom block device mappings with EBS encryption
- Scale up and scale down policies with cooldown periods
- SNS notifications for scaling events
- Instance refresh with rolling deployment strategy
- Comprehensive tagging across all resources

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- IAM permissions for EC2, Auto Scaling, SNS (for notifications)
- Existing VPC with subnets
- Security groups for instances
- AMI ID for instance launch

---

## Usage Example

```hcl
module "autoscaling" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/AutoScaling?ref=v2.0.0"

  name_prefix      = "my-app"
  ami_id          = "ami-12345678"
  instance_type   = "t3.medium"
  key_name        = "my-key-pair"
  
  # User data script for instance initialization
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
  EOF

  # Network configuration
  subnet_ids         = ["subnet-12345", "subnet-67890"]
  security_group_ids = ["sg-12345678"]
  
  # Auto Scaling configuration
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  target_group_arns         = ["arn:aws:elasticloadbalancing:us-east-1:123456789012:targetgroup/my-targets/abc123"]

  # IAM configuration
  iam_instance_profile = "my-instance-profile"

  # Storage configuration
  block_device_mappings = {
    root = {
      device_name = "/dev/xvda"
      ebs = {
        volume_size = 20
        volume_type = "gp3"
        encrypted   = true
      }
    }
  }

  # Scaling policies
  enable_scale_up_policy   = true
  enable_scale_down_policy = true
  scaling_adjustment_type  = "ChangeInCapacity"
  scale_up_adjustment      = 1
  scale_down_adjustment    = -1
  scale_up_cooldown        = 300
  scale_down_cooldown      = 300

  # Notifications
  enable_notifications    = true
  notification_topic_arn  = "arn:aws:sns:us-east-1:123456789012:autoscaling-notifications"
  notification_types      = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  tags = {
    Environment = "Production"
    Application = "WebApp"
    Owner       = "DevOps Team"
  }
}
```

## Module Structure

```
modules
└── AutoScaling
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  └── README.md
  └── examples
    └── simple
      ├── main.tf
      ├── versions.tf
      └── README.md
```

---

## Resources Used

| Resource                           | Purpose                                         |
|-----------------------------------|------------------------------------------------- |
| `aws_launch_template`             | Defines instance configuration template          |
| `aws_autoscaling_group`           | Creates and manages the Auto Scaling Group       |
| `aws_autoscaling_policy`          | Creates scale up policy (conditional)            |
| `aws_autoscaling_policy`          | Creates scale down policy (conditional)          |
| `aws_autoscaling_notification`    | Configures SNS notifications (conditional)       |

---

## Input Variables

| Name                          | Type   | Description                                                    | Required |
|-------------------------------|--------|----------------------------------------------------------------|----------|
| `name_prefix`                 | string | Prefix for resource names                                      | Yes      |
| `ami_id`                      | string | AMI ID for EC2 instances                                       | Yes      |
| `instance_type`               | string | EC2 instance type                                              | Yes      |
| `key_name`                    | string | EC2 Key Pair name for SSH access                               | Yes      |
| `user_data`                   | string | User data script for instance initialization                   | No       |
| `security_group_ids`          | list   | List of security group IDs                                     | Yes      |
| `subnet_ids`                  | list   | List of subnet IDs for ASG                                     | Yes      |
| `min_size`                    | number | Minimum number of instances                                    | Yes      |
| `max_size`                    | number | Maximum number of instances                                    | Yes      |
| `desired_capacity`            | number | Desired number of instances                                    | Yes      |
| `health_check_type`           | string | Type of health check (EC2 or ELB)                              | Yes      |
| `health_check_grace_period`   | number | Health check grace period in seconds                           | Yes      |
| `termination_policies`        | list   | Termination policies for ASG                                   | No       |
| `target_group_arns`           | list   | List of target group ARNs for load balancer                    | No       |
| `iam_instance_profile`        | string | IAM instance profile name                                      | No       |
| `block_device_mappings`       | map    | Block device mappings configuration                            | No       |
| `enable_scale_up_policy`      | bool   | Enable automatic scale up policy                               | No       |
| `enable_scale_down_policy`    | bool   | Enable automatic scale down policy                             | No       |
| `scaling_adjustment_type`     | string | Scaling adjustment type                                        | No       |
| `scale_up_adjustment`         | number | Number of instances to add during scale up                     | No       |
| `scale_down_adjustment`       | number | Number of instances to remove during scale down                | No       |
| `scale_up_cooldown`           | number | Cooldown period for scale up in seconds                        | No       |
| `scale_down_cooldown`         | number | Cooldown period for scale down in seconds                      | No       |
| `enable_notifications`        | bool   | Enable SNS notifications                                       | No       |
| `notification_topic_arn`      | string | SNS topic ARN for notifications                                | No       |
| `notification_types`          | list   | List of notification types                                     | No       |
| `tags`                        | map    | Tags to apply to resources                                     | Yes      |

---

## Outputs

| Name                      | Description                                                           |
|---------------------------|-----------------------------------------------------------------------|
| `launch_template_id`      | The ID of the created launch template                                 |
| `launch_template_arn`     | The ARN of the created launch template                                |
| `autoscaling_group_id`    | The ID of the Auto Scaling Group                                      |
| `autoscaling_group_arn`   | The ARN of the Auto Scaling Group                                     |
| `autoscaling_group_name`  | The name of the Auto Scaling Group                                    |
| `scale_up_policy_arn`     | The ARN of the scale up policy (if enabled)                           |
| `scale_down_policy_arn`   | The ARN of the scale down policy (if enabled)                         |

---

## Best Practices

- **Instance Types**: Choose appropriate instance types based on workload requirements and cost optimization.
- **Health Checks**: Use ELB health checks when instances are behind a load balancer for more accurate health detection.
- **Termination Policies**: Configure appropriate termination policies to ensure optimal instance replacement.
- **Scaling Policies**: Set reasonable cooldown periods to prevent rapid scaling events and unnecessary costs.
- **Instance Refresh**: The module includes rolling instance refresh to ensure zero-downtime deployments.
- **Encryption**: Always encrypt EBS volumes using the `encrypted = true` parameter in block device mappings.
- **Monitoring**: Enable SNS notifications to track scaling events and potential issues.
- **User Data**: Keep user data scripts lightweight and idempotent for faster instance launch times.
- **Security**: Limit security group access and use IAM instance profiles with least privilege principles.
- **Subnets**: Distribute instances across multiple Availability Zones for high availability.
- **Capacity**: Set `desired_capacity` thoughtfully and use `ignore_changes = [desired_capacity]` to prevent Terraform from overriding manual scaling.

---
