provider "aws" {
  region = var.region
}

variable "region" {
  default = "us-east-1"
}

# Data source for availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "alb-example-vpc"
    Environment = "example"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "alb-example-igw"
    Environment = "example"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name        = "alb-example-public-subnet-${count.index + 1}"
    Environment = "example"
    Type        = "Public"
  }
}

# Private Subnets (for NLB example)
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "alb-example-private-subnet-${count.index + 1}"
    Environment = "example"
    Type        = "Private"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "alb-example-public-rt"
    Environment = "example"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Elastic IPs for NLB (optional)
resource "aws_eip" "nlb" {
  count = 2

  domain = "vpc"

  tags = {
    Name        = "alb-example-nlb-eip-${count.index + 1}"
    Environment = "example"
  }

  depends_on = [aws_internet_gateway.main]
}

# Target Groups for ALB Example
resource "aws_lb_target_group" "web" {
  name     = "alb-example-web-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "alb-example-web-tg"
    Environment = "example"
  }
}

resource "aws_lb_target_group" "api" {
  name     = "alb-example-api-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "alb-example-api-tg"
    Environment = "example"
  }
}

resource "aws_lb_target_group" "admin" {
  name     = "alb-example-admin-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/admin/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "alb-example-admin-tg"
    Environment = "example"
  }
}

# Target Groups for NLB Example
resource "aws_lb_target_group" "nlb_app" {
  name     = "alb-example-nlb-app-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 3
    interval            = 30
    port                = "traffic-port"
    protocol            = "TCP"
    timeout             = 6
    unhealthy_threshold = 3
  }

  tags = {
    Name        = "alb-example-nlb-app-tg"
    Environment = "example"
  }
}

# Self-signed certificate for HTTPS example (not for production use)
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "tls_self_signed_cert" "example" {
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.local"
    organization = "Example Organization"
  }

  validity_period_hours = 8760 # 1 year

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "example" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem

  tags = {
    Name        = "alb-example-cert"
    Environment = "example"
  }
}

# Public ALB Example with Listeners and Rules
module "public_alb" {
  source = "../../"

  name                       = "example-public-web"
  lb_type                    = "application"
  internal                   = false
  vpc_id                     = aws_vpc.main.id
  subnet_ids                 = aws_subnet.public[*].id
  idle_timeout               = 120
  enable_deletion_protection = false # Set to false for example/testing

  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "ingress"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  # Listeners Configuration
  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      default_action = {
        type = "redirect"
        redirect = {
          port        = "443"
          protocol    = "HTTPS"
          status_code = "HTTP_301"
        }
      }
    }
    https = {
      port            = 443
      protocol        = "HTTPS"
      ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
      certificate_arn = aws_acm_certificate.example.arn
      default_action = {
        type             = "forward"
        target_group_arn = aws_lb_target_group.web.arn
      }
    }
  }

  # Listener Rules Configuration
  listener_rules = {
    api_rule = {
      listener_key = "https"
      priority     = 100
      conditions = [
        {
          path_pattern = {
            values = ["/api/*"]
          }
        }
      ]
      actions = [
        {
          type             = "forward"
          target_group_arn = aws_lb_target_group.api.arn
        }
      ]
    }
    admin_rule = {
      listener_key = "https"
      priority     = 200
      conditions = [
        {
          path_pattern = {
            values = ["/admin/*"]
          }
        }
      ]
      actions = [
        {
          type             = "forward"
          target_group_arn = aws_lb_target_group.admin.arn
        }
      ]
    }
    maintenance_rule = {
      listener_key = "https"
      priority     = 300
      conditions = [
        {
          path_pattern = {
            values = ["/maintenance"]
          }
        }
      ]
      actions = [
        {
          type = "fixed-response"
          fixed_response = {
            content_type = "text/html"
            message_body = "<html><body><h1>Site Under Maintenance</h1><p>Please check back later.</p></body></html>"
            status_code  = "503"
          }
        }
      ]
    }
    health_check_rule = {
      listener_key = "https"
      priority     = 50
      conditions = [
        {
          path_pattern = {
            values = ["/health", "/status"]
          }
        }
      ]
      actions = [
        {
          type = "fixed-response"
          fixed_response = {
            content_type = "application/json"
            message_body = "{\"status\":\"healthy\",\"version\":\"1.0\"}"
            status_code  = "200"
          }
        }
      ]
    }
  }

  tags = {
    Environment = "sandbox"
    Service     = "web"
    Purpose     = "alb-testing"
  }
}

# Private NLB Example with TCP Listeners
module "private_nlb" {
  source = "../../"

  name                       = "example-private-app"
  lb_type                    = "network"
  vpc_id                     = aws_vpc.main.id
  internal                   = true
  subnet_ids                 = aws_subnet.private[*].id
  enable_deletion_protection = false # Set to false for example/testing

  # NLB Listeners Configuration
  listeners = {
    tcp_80 = {
      port     = 80
      protocol = "TCP"
      default_action = {
        type             = "forward"
        target_group_arn = aws_lb_target_group.nlb_app.arn
      }
    }
    tcp_443 = {
      port     = 443
      protocol = "TCP"
      default_action = {
        type             = "forward"
        target_group_arn = aws_lb_target_group.nlb_app.arn
      }
    }
  }

  tags = {
    Environment = "sandbox"
    Service     = "application"
    Purpose     = "nlb-testing"
  }
}


# ALB Outputs
output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.public_alb.dns_name
}

output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = module.public_alb.arn
}

output "alb_zone_id" {
  description = "Route53 zone ID of the Application Load Balancer"
  value       = module.public_alb.zone_id
}

output "alb_listener_arns" {
  description = "ARNs of ALB listeners"
  value       = module.public_alb.listener_arns
}

output "alb_listener_rule_arns" {
  description = "ARNs of ALB listener rules"
  value       = module.public_alb.listener_rule_arns
}

# NLB Outputs
output "nlb_dns_name" {
  description = "DNS name of the Network Load Balancer"
  value       = module.private_nlb.dns_name
}

output "nlb_arn" {
  description = "ARN of the Network Load Balancer"
  value       = module.private_nlb.arn
}

output "nlb_zone_id" {
  description = "Route53 zone ID of the Network Load Balancer"
  value       = module.private_nlb.zone_id
}

output "nlb_listener_arns" {
  description = "ARNs of NLB listeners"
  value       = module.private_nlb.listener_arns
}

# Target Group Outputs
output "target_group_arns" {
  description = "ARNs of the target groups"
  value = {
    web     = aws_lb_target_group.web.arn
    api     = aws_lb_target_group.api.arn
    admin   = aws_lb_target_group.admin.arn
    nlb_app = aws_lb_target_group.nlb_app.arn
  }
}

# Certificate Output
output "certificate_arn" {
  description = "ARN of the self-signed certificate"
  value       = aws_acm_certificate.example.arn
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "example"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "alb-example"
}
