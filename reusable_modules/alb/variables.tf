variable "name" {
  description = "Resource name prefix"
  type        = string
}

variable "lb_type" {
  description = "Load balancer type (application/network)"
  type        = string
  default     = "application"
}

variable "internal" {
  description = "Internal load balancer (true/false)"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "Subnet IDs for LB placement"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "security_group_rules" {
  description = "Custom security group rules"
  type = list(object({
    type        = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = []
}

variable "eip_allocations" {
  description = "EIP allocations for NLB (one per subnet)"
  type        = list(string)
  default     = []
}

variable "access_logs_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "idle_timeout" {
  description = "ALB idle timeout (seconds)"
  type        = number
  default     = 60
}

variable "enable_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "private_ips" {
  description = "Private IP addresses for internal load balancer (one per subnet)"
  type        = list(string)
  default     = []
}

# Listener Configuration
variable "listeners" {
  description = "Map of listener configurations"
  type = map(object({
    port                = number
    protocol            = string
    ssl_policy          = optional(string)
    certificate_arn     = optional(string)
    alpn_policy         = optional(string)
    default_action = object({
      type                 = string
      target_group_arn     = optional(string)
      target_group_key     = optional(string)  # NEW: Reference to target_groups key
      redirect = optional(object({
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
        status_code = string
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
      forward = optional(object({
        target_groups = list(object({
          arn    = string  # Can now be either ARN or target group key
          weight = optional(number, 100)
        }))
        stickiness = optional(object({
          enabled  = optional(bool, false)
          duration = optional(number, 1)
        }))
      }))
    })
  }))
  default = {}
}

# Listener Rules Configuration
variable "listener_rules" {
  description = "Map of listener rule configurations"
  type = map(object({
    listener_key = string
    priority     = optional(number)
    conditions = list(object({
      host_header = optional(object({
        values = list(string)
      }))
      path_pattern = optional(object({
        values = list(string)
      }))
      http_header = optional(object({
        http_header_name = string
        values           = list(string)
      }))
      http_request_method = optional(object({
        values = list(string)
      }))
      query_string = optional(list(object({
        key   = optional(string)
        value = string
      })))
      source_ip = optional(object({
        values = list(string)
      }))
    }))
    actions = list(object({
      type  = string
      order = optional(number, 100)
      target_group_arn = optional(string)
      redirect = optional(object({
        host        = optional(string)
        path        = optional(string)
        port        = optional(string)
        protocol    = optional(string)
        query       = optional(string)
        status_code = string
      }))
      fixed_response = optional(object({
        content_type = string
        message_body = optional(string)
        status_code  = string
      }))
      forward = optional(object({
        target_groups = list(object({
          arn    = string
          weight = optional(number, 100)
        }))
        stickiness = optional(object({
          enabled  = optional(bool, false)
          duration = optional(number, 1)
        }))
      }))
    }))
  }))
  default = {}
}

# Target Groups Configuration
variable "target_groups" {
  description = "Map of target group configurations"
  type = map(object({
    name        = string
    port        = number
    protocol    = string
    target_type = optional(string, "instance")
    health_check = optional(object({
      path                = optional(string, "/")
      interval            = optional(number, 30)
      timeout             = optional(number, 5)
      healthy_threshold   = optional(number, 2)
      unhealthy_threshold = optional(number, 2)
      matcher             = optional(string, "200-399")
    }), {})
  }))
  default = {}
}

# Target Group Attachments Configuration
variable "target_group_attachments" {
  description = "Map of target group attachment configurations"
  type = map(object({
    target_group_key = string
    target_ids       = list(string)
    port             = optional(number, 80)
  }))
  default = {}
}
