resource "aws_launch_template" "main" {
  name_prefix   = var.name_prefix
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  user_data     = var.user_data != null ? base64encode(var.user_data) : null
  vpc_security_group_ids = var.security_group_ids

  dynamic "iam_instance_profile" {
    for_each = var.iam_instance_profile != null ? [1] : []
    content {
      name = var.iam_instance_profile
    }
  }

  dynamic "block_device_mappings" {
    for_each = var.block_device_mappings
    content {
      device_name = block_device_mappings.value.device_name
      ebs {
        volume_size = block_device_mappings.value.ebs.volume_size
        volume_type = block_device_mappings.value.ebs.volume_type
        encrypted   = block_device_mappings.value.ebs.encrypted
      }
    }
  }

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.tags, {
      Name = "${var.name_prefix}-instance"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_autoscaling_group" "main" {
  name_prefix               = "${var.name_prefix}-asg-"
  min_size                  = var.min_size
  max_size                  = var.max_size
  desired_capacity          = var.desired_capacity
  vpc_zone_identifier       = var.subnet_ids
  health_check_type         = var.health_check_type
  health_check_grace_period = var.health_check_grace_period
  termination_policies      = var.termination_policies
  target_group_arns         = var.target_group_arns

  launch_template {
    id      = aws_launch_template.main.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 90
    }
    # triggers = ["launch_template"]
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [desired_capacity]
  }
}

# Scale Up Policy
resource "aws_autoscaling_policy" "scale_up" {
  count = var.enable_scale_up_policy ? 1 : 0

  name                   = "${var.name_prefix}-scale-up"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = var.scaling_adjustment_type
  scaling_adjustment     = var.scale_up_adjustment
  cooldown               = var.scale_up_cooldown
}

# Scale Down Policy
resource "aws_autoscaling_policy" "scale_down" {
  count = var.enable_scale_down_policy ? 1 : 0

  name                   = "${var.name_prefix}-scale-down"
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.main.name
  adjustment_type        = var.scaling_adjustment_type
  scaling_adjustment     = var.scale_down_adjustment
  cooldown               = var.scale_down_cooldown
}

# Notifications
resource "aws_autoscaling_notification" "asg_notifications" {
  count = var.enable_notifications && var.notification_topic_arn != "" ? 1 : 0

  group_names   = [aws_autoscaling_group.main.name]
  notifications = var.notification_types
  topic_arn     = var.notification_topic_arn
}
