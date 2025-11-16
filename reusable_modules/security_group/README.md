# Security Group Terraform Module

This module provisions **AWS Security Groups** with flexible ingress and egress rule configurations for VPC resources.

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
- Security group creation with custom name and description
- Flexible ingress and egress rule configuration
- Support for CIDR blocks, IPv6 CIDR blocks, and security group references
- Self-referencing rules
- Comprehensive rule descriptions
- Resource tagging

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- IAM permissions for EC2 Security Groups
- Existing VPC where security groups will be created

---

## Usage Example

```hcl
module "web_security_group" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/security_group?ref=main"

  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = "vpc-12345678"

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access from anywhere"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH access from private networks"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "production"
    Team        = "infrastructure"
  }
}
```

## Module Structure

```
modules/
└── security_group/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── README.md
    └── example/
        └── simple/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── provider.tf
            ├── versions.tf
            └── README.md
```

---

## Resources Used

| Resource                     | Purpose                                    |
|------------------------------|-------------------------------------------|
| `aws_security_group`         | Creates the security group               |
| `aws_security_group_rule`    | Creates ingress and egress rules         |

---

## Input Variables

| Name           | Type   | Description                              | Required |
|----------------|--------|------------------------------------------|----------|
| `name`         | string | Name of the security group              | Yes      |
| `description`  | string | Description of the security group       | No       |
| `vpc_id`       | string | VPC ID where security group is created  | Yes      |
| `ingress_rules`| list   | List of ingress rule configurations     | No       |
| `egress_rules` | list   | List of egress rule configurations      | No       |
| `tags`         | map    | Tags to apply to the security group     | No       |

### Rule Configuration

Each rule in `ingress_rules` and `egress_rules` supports:

| Field                      | Type   | Description                           | Required |
|----------------------------|--------|---------------------------------------|----------|
| `from_port`               | number | Starting port number                  | Yes      |
| `to_port`                 | number | Ending port number                    | Yes      |
| `protocol`                | string | Protocol (tcp, udp, icmp, or -1)      | Yes      |
| `cidr_blocks`             | list   | List of CIDR blocks                   | No       |
| `ipv6_cidr_blocks`        | list   | List of IPv6 CIDR blocks              | No       |
| `source_security_group_id`| string | Source security group ID             | No       |
| `self`                    | bool   | Allow traffic from/to same SG        | No       |
| `description`             | string | Description of the rule               | No       |

---

## Outputs

| Name                        | Description                           |
|-----------------------------|---------------------------------------|
| `security_group_id`         | ID of the created security group     |
| `security_group_arn`        | ARN of the created security group    |
| `security_group_name`       | Name of the created security group   |
| `security_group_description`| Description of the security group    |
| `security_group_vpc_id`     | VPC ID of the security group         |
| `ingress_rules`             | List of ingress rules                 |
| `egress_rules`              | List of egress rules                  |

---

## Best Practices

- Use descriptive names and descriptions for security groups
- Follow the principle of least privilege for rules
- Use security group references instead of CIDR blocks when possible
- Document each rule with meaningful descriptions
- Group related rules into the same security group
- Use separate security groups for different tiers (web, app, database)
- Regularly audit and review security group rules
- Tag security groups for better organization and cost tracking
- Avoid using 0.0.0.0/0 for ingress rules unless absolutely necessary
- Use specific ports instead of port ranges when possible

---