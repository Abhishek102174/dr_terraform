# Route 53 Zone and Health Check Terraform Module

This Terraform module provisions an **Amazon Route 53 hosted zone** (public or private) and an optional **health check** to monitor endpoint availability.

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module provides:

- Creation of a **Route 53 hosted zone** (public or private)
- Optional **VPC association** for private zones
- Optional **Route 53 health check** (with support for HTTP, HTTPS, TCP)

---

## Features

- Public or private zone configuration
- Conditional creation of health checks
- HTTPS toggle for health check protocol and port
- Clean and tagged DNS configuration
- Compatible with AWS multi-region health monitoring

---

## Prerequisites

- Terraform ≥ 1.12.1
- AWS provider ≥ 5.0
- IAM permissions to manage Route 53 zones and health checks

---

## Usage

```hcl
module "dns_zone" {
  source       = "../../modules/route53"
  domain_name  = "example.com"
  comment      = "Managed by Terraform"
  private_zone = true
  vpc_associations = [
    {
      vpc_id     = "vpc-123abc"
      vpc_region = "us-east-1"
    }
  ]
  enable_https         = true
  health_check_fqdn    = "app.example.com"
  health_check_path    = "/health"
  health_check_regions = ["us-east-1", "us-west-2"]
  tags = {
    Environment = "prod"
    Owner       = "devops-team"
  }
}
```

---

## Module Structure

```
modules/
└── route53/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
    └── examples
    └── simple
      ├── main.tf
      ├── versions.tf
      └──README.md
```
```

---

## Resources Created

| Resource Type               | Description                              |
|----------------------------|------------------------------------------|
| `aws_route53_zone`         | Creates a Route 53 hosted zone           |
| `aws_route53_health_check` | (Optional) Creates a health check        |

---

## Input Variables

| Name                   | Type      | Description                                          | Required |
|------------------------|-----------|------------------------------------------------------|----------|
| `domain_name`          | string    | Name of the DNS zone (e.g., `example.com`)           | Yes      |
| `comment`              | string    | Comment to associate with the hosted zone            | No       |
| `private_zone`         | bool      | Whether the zone is private (true) or public (false) | Yes      |
| `vpc_associations`     | list(map) | List of VPCs to associate (only if `private_zone`)   | No       |
| `enable_https`         | bool      | Whether to use HTTPS for health checks               | No       |
| `health_check_fqdn`    | string    | FQDN to monitor for health check                     | No       |
| `health_check_path`    | string    | Path for HTTP/HTTPS health check (e.g., `/health`)   | No       |
| `health_check_regions` | list      | AWS regions for health check probing                 | No       |
| `tags`                 | map       | Tags to apply to all resources                       | No       |

---

## Outputs

| Name                  | Description                                |
|-----------------------|--------------------------------------------|
| `zone_id`             | The ID of the created hosted zone          |
| `zone_name`           | The name of the hosted zone                |
| `health_check_id`     | ID of the created health check (if any)    |

---

## Best Practices

- Use health checks to route traffic away from unhealthy endpoints.
- For private zones, ensure VPC associations are properly scoped.
- Tag DNS resources consistently for cost tracking and ownership.
- Use CloudWatch alarms to monitor health check failures in production.

---
