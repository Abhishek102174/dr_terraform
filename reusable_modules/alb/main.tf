# Security Group (ALB only)
resource "aws_security_group" "lb_sg" {
  count       = var.lb_type == "application" ? 1 : 0
  name_prefix = "${var.name}"
  vpc_id      = var.vpc_id
  tags        = merge(var.tags, { Name = "${var.name}" })
  lifecycle {
    create_before_destroy = true
  }
}

# Security Group Rules
resource "aws_security_group_rule" "custom_rules" {
  for_each = {
    for idx, rule in var.security_group_rules : idx => rule
    if var.lb_type == "application"
  }
  security_group_id = aws_security_group.lb_sg[0].id
  type              = each.value.type
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
}

# Load Balancer
resource "aws_lb" "main" {
  name               = var.name
  internal           = var.internal
  load_balancer_type = var.lb_type
  security_groups    = var.lb_type == "application" ? [aws_security_group.lb_sg[0].id] : null

  # Use subnets for simple cases (no EIPs, no specific private IPs)
  subnets = (length(var.eip_allocations) == 0 && length(var.private_ips) == 0) ? var.subnet_ids : null

  # Use subnet_mapping when EIPs or specific private IPs are needed
  dynamic "subnet_mapping" {
    for_each = (length(var.eip_allocations) > 0 || length(var.private_ips) > 0) ? var.subnet_ids : []
    content {
      subnet_id            = subnet_mapping.value
      allocation_id        = var.lb_type == "network" && length(var.eip_allocations) > 0 ? var.eip_allocations[index(var.subnet_ids, subnet_mapping.value)] : null
      private_ipv4_address = var.internal && length(var.private_ips) > 0 ? var.private_ips[index(var.subnet_ids, subnet_mapping.value)] : null
    }
  }

  # Access Logging (ALB only)
  access_logs {
    enabled = var.lb_type == "application" && var.access_logs_bucket != ""
    bucket  = var.access_logs_bucket
    prefix  = "${var.name}"
  }

  # ALB specific settings
  idle_timeout               = var.lb_type == "application" ? var.idle_timeout : null
  enable_deletion_protection = var.enable_deletion_protection
  tags                       = var.tags
}

# Load Balancer Listeners (Enhanced with automatic target group linking)
resource "aws_lb_listener" "main" {
  for_each          = var.listeners
  load_balancer_arn = aws_lb.main.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.ssl_policy
  certificate_arn   = each.value.certificate_arn
  alpn_policy       = each.value.alpn_policy

  # Enhanced Default Action with automatic target group resolution
  default_action {
    type = each.value.default_action.type
    
    # Automatically resolve target group ARN if target_group_key is provided
    target_group_arn = each.value.default_action.target_group_key != null ? aws_lb_target_group.main[each.value.default_action.target_group_key].arn : each.value.default_action.target_group_arn

    # Redirect Action
    dynamic "redirect" {
      for_each = each.value.default_action.redirect != null ? [each.value.default_action.redirect] : []
      content {
        host        = redirect.value.host
        path        = redirect.value.path
        port        = redirect.value.port
        protocol    = redirect.value.protocol
        query       = redirect.value.query
        status_code = redirect.value.status_code
      }
    }

    # Fixed Response Action
    dynamic "fixed_response" {
      for_each = each.value.default_action.fixed_response != null ? [each.value.default_action.fixed_response] : []
      content {
        content_type = fixed_response.value.content_type
        message_body = fixed_response.value.message_body
        status_code  = fixed_response.value.status_code
      }
    }

    # Enhanced Forward Action with automatic target group resolution
    dynamic "forward" {
      for_each = each.value.default_action.forward != null ? [each.value.default_action.forward] : []
      content {
        dynamic "target_group" {
          for_each = forward.value.target_groups
          content {
            # Automatically resolve ARN from key if it's a reference to target_groups
            arn    = can(aws_lb_target_group.main[target_group.value.arn]) ? aws_lb_target_group.main[target_group.value.arn].arn : target_group.value.arn
            weight = target_group.value.weight
          }
        }
        dynamic "stickiness" {
          for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
          content {
            enabled  = stickiness.value.enabled
            duration = stickiness.value.duration
          }
        }
      }
    }
  }
  tags = var.tags
}

# Load Balancer Listener Rules
resource "aws_lb_listener_rule" "main" {
  for_each     = var.listener_rules
  listener_arn = aws_lb_listener.main[each.value.listener_key].arn
  priority     = each.value.priority

  # Conditions
  dynamic "condition" {
    for_each = each.value.conditions
    content {
      # Host Header Condition
      dynamic "host_header" {
        for_each = condition.value.host_header != null ? [condition.value.host_header] : []
        content {
          values = host_header.value.values
        }
      }

      # Path Pattern Condition
      dynamic "path_pattern" {
        for_each = condition.value.path_pattern != null ? [condition.value.path_pattern] : []
        content {
          values = path_pattern.value.values
        }
      }

      # HTTP Header Condition
      dynamic "http_header" {
        for_each = condition.value.http_header != null ? [condition.value.http_header] : []
        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }

      # HTTP Request Method Condition
      dynamic "http_request_method" {
        for_each = condition.value.http_request_method != null ? [condition.value.http_request_method] : []
        content {
          values = http_request_method.value.values
        }
      }

      # Query String Condition
      dynamic "query_string" {
        for_each = condition.value.query_string != null ? condition.value.query_string : []
        content {
          key   = query_string.value.key
          value = query_string.value.value
        }
      }

      # Source IP Condition
      dynamic "source_ip" {
        for_each = condition.value.source_ip != null ? [condition.value.source_ip] : []
        content {
          values = source_ip.value.values
        }
      }
    }
  }

  # Actions
  dynamic "action" {
    for_each = each.value.actions
    content {
      type             = action.value.type
      order            = action.value.order
      target_group_arn = action.value.target_group_arn

      # Redirect Action
      dynamic "redirect" {
        for_each = action.value.redirect != null ? [action.value.redirect] : []
        content {
          host        = redirect.value.host
          path        = redirect.value.path
          port        = redirect.value.port
          protocol    = redirect.value.protocol
          query       = redirect.value.query
          status_code = redirect.value.status_code
        }
      }

      # Fixed Response Action
      dynamic "fixed_response" {
        for_each = action.value.fixed_response != null ? [action.value.fixed_response] : []
        content {
          content_type = fixed_response.value.content_type
          message_body = fixed_response.value.message_body
          status_code  = fixed_response.value.status_code
        }
      }

      # Forward Action
      dynamic "forward" {
        for_each = action.value.forward != null ? [action.value.forward] : []
        content {
          dynamic "target_group" {
            for_each = forward.value.target_groups
            content {
              arn    = target_group.value.arn
              weight = target_group.value.weight
            }
          }
          dynamic "stickiness" {
            for_each = forward.value.stickiness != null ? [forward.value.stickiness] : []
            content {
              enabled  = stickiness.value.enabled
              duration = stickiness.value.duration
            }
          }
        }
      }
    }
  }

  tags = var.tags
}

# Target Groups
resource "aws_lb_target_group" "main" {
  for_each    = var.target_groups
  name        = each.value.name
  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = each.value.target_type

  health_check {
    path                = each.value.health_check.path
    interval            = each.value.health_check.interval
    timeout             = each.value.health_check.timeout
    healthy_threshold   = each.value.health_check.healthy_threshold
    unhealthy_threshold = each.value.health_check.unhealthy_threshold
    matcher             = each.value.health_check.matcher
  }

  tags = var.tags
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "main" {
  for_each = {
    for attachment_key, attachment in var.target_group_attachments :
    attachment_key => {
      for target_idx, target_id in attachment.target_ids :
      "${attachment_key}-${target_idx}" => {
        target_group_arn = aws_lb_target_group.main[attachment.target_group_key].arn
        target_id        = target_id
        port             = attachment.port
      }
    }
  }
  
  target_group_arn = each.value.target_group_arn
  target_id        = each.value.target_id
  port             = each.value.port
}

