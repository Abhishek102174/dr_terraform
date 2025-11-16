# Detailed AWS Application/Network Load Balancer Terraform Module

This module provisions an **AWS Application Load Balancer (ALB)** or **Network Load Balancer (NLB)** with enhanced configuration including security groups, access logging, subnet mapping, and flexible networking options.

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
- Application Load Balancer (ALB) and Network Load Balancer (NLB) creation
- Automatic security group creation and rule management (ALB only)
- Elastic IP allocation support for Network Load Balancers
- Private IP address assignment for internal load balancers
- Access logging configuration (ALB only)
- Flexible subnet mapping with advanced networking options
- Deletion protection and idle timeout configuration
- Custom tags and naming conventions
- Internet-facing or internal load balancer deployment

---

## Prerequisites

- Terraform CLI >= 1.12.0
- AWS Provider >= 5.4
- AWS CLI configured with proper permissions
- IAM permissions for EC2, VPC, and Load Balancer services
- Existing VPC and subnets for load balancer deployment
- S3 bucket for access logs (if logging enabled)

---

## Usage Example

```hcl
module "application_load_balancer" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/ALB?ref=v2.0.0"

  name    = "my-application-lb"
  lb_type = "application"
  vpc_id  = "vpc-12345678"
  internal = false
  
  subnet_ids = [
    "subnet-12345678",
    "subnet-87654321"
  ]
  
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
  
  access_logs_bucket = "my-alb-access-logs"
  idle_timeout = 60
  enable_deletion_protection = false
  
  tags = {
    Environment = "production"
    Application = "web-app"
    ManagedBy   = "Terraform"
  }
}

# Network Load Balancer with Elastic IPs
module "network_load_balancer" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/ALB?ref=main"

  name     = "my-network-lb"
  lb_type  = "network"
  internal = false
  
  subnet_ids = [
    "subnet-12345678",
    "subnet-87654321"
  ]
  
  eip_allocations = [
    "eipalloc-12345678",
    "eipalloc-87654321"
  ]
  
  tags = {
    Environment = "production"
    Application = "api-gateway"
  }
}
```

## Module Structure

```
modules
└── ALB
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  └── README.md
  └── examples
    └── simple
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      └── README.md
```

---

## Resources Used

| Resource                           | Purpose                                        |
|-----------------------------------|------------------------------------------------|
| `aws_lb`                          | Creates the Application/Network Load Balancer |
| `aws_security_group`              | Creates security group (ALB only)             |
| `aws_security_group_rule`         | Manages security group rules (ALB only)       |

---

## Input Variables

| Name                        | Type           | Description                                                                      | Required |
|----------------------------|----------------|-----------------------------------------------------------------------------------|----------|
| `name`                     | string         | Name of the load balancer                                                         | Yes      |
| `lb_type`                  | string         | Type of load balancer (`application`, `network`, `gateway`)                       | No       |
| `vpc_id`                   | string         | VPC ID where load balancer will be created (Required for ALB)                     | No       |
| `subnet_ids`               | list(string)   | List of subnet IDs to attach to the load balancer                                 | Yes      |
| `internal`                 | bool           | Whether the load balancer is internal or internet-facing                          | No       |
| `security_group_rules`     | list(object)   | List of security group rules for ALB                                              | No       |
| `eip_allocations`          | list(string)   | List of Elastic IP allocation IDs for NLB                                         | No       |
| `private_ips`              | list(string)   | List of private IP addresses for internal load balancers                          | No       |
| `access_logs_bucket`       | string         | S3 bucket name for ALB access logs                                                | No       |
| `idle_timeout`             | number         | Time in seconds connections are allowed to be idle (ALB only)                     | No       |
| `enable_deletion_protection` | bool         | Enable deletion protection on the load balancer                                   | No       |
| `tags`                     | map(string)    | Map of tags to apply to resources                                                 | No       |

### Security Group Rules Object Structure

```hcl
security_group_rules = [
  {
    type        = "ingress"           # "ingress" or "egress"
    from_port   = 80                  # Starting port number
    to_port     = 80                  # Ending port number
    protocol    = "tcp"               # Protocol (tcp, udp, icmp, or -1 for all)
    cidr_blocks = ["0.0.0.0/0"]      # List of CIDR blocks
  }
]
```

---

## Outputs

| Name                    | Description                                           |
|------------------------|-------------------------------------------------------|
| `load_balancer_arn`    | ARN of the created load balancer                     |
| `load_balancer_dns_name` | DNS name of the load balancer for routing traffic  |
| `load_balancer_zone_id` | Canonical hosted zone ID of the load balancer      |
| `security_group_id`    | ID of the security group created (ALB only)          |

---

## Best Practices

- **Security Groups**: ALBs automatically create security groups; NLBs operate at Layer 4 and don't use security groups
- **Subnet Planning**: Use subnets across multiple Availability Zones for high availability
- **Access Logging**: Enable access logging for ALBs to monitor traffic patterns and troubleshoot issues
- **Deletion Protection**: Enable deletion protection in production environments to prevent accidental deletion
- **EIP Allocation**: For NLBs, use Elastic IP allocations to maintain static IP addresses
- **Internal vs External**: Use internal load balancers for private application traffic within VPC
- **Tagging Strategy**: Implement consistent tagging for resource management and cost allocation
- **Idle Timeout**: Configure appropriate idle timeout values based on application requirements (ALB only)
- **Subnet Mapping**: Use subnet mapping when you need specific IP assignments or EIP allocations

---
