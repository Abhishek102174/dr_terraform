# Route 53 Zones and Health Checks - Usage Example

This example demonstrates how to use the Route 53 Terraform module to provision:

- A **public hosted zone** with health check
- A **private hosted zone** associated with a VPC
- A **standalone HTTPS health check** (no hosted zone)

---

## Table of Contents

- [Overview](#overview)
- [Infrastructure](#infrastructure)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Deployed](#resources-deployed)
- [Best Practices](#best-practices)

---

## Overview

This example showcases three different use cases of the Route 53 module:
- Creating a **public zone** with FQDN health check
- Creating a **private zone** with VPC association
- Configuring an **HTTPS health check** without a hosted zone

---

## Infrastructure

- A new **VPC** for the private zone association
- Three Route 53 module usages:
  - `public_zone`
  - `private_zone`
  - `https_health_check`

---

## Prerequisites

- Terraform ≥ 1.12.1
- AWS provider ≥ 5.0
- IAM permissions to manage Route 53 and VPC

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# VPC for private zone
resource "aws_vpc" "private" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "private-zone-vpc"
  }
}

data "aws_region" "current" {}

# Public Hosted Zone
module "public_zone" {
  source               = "../../"
  domain_name          = "public.waters.com"
  health_check_fqdn    = "app.public.waters.com"
  health_check_regions = ["us-east-1", "eu-west-1", "us-west-2"]
  tags = {
    Environment = "sandbox"
  }
}

# Private Hosted Zone
module "private_zone" {
  source       = "../../"
  domain_name  = "private.waters.net"
  private_zone = true
  vpc_associations = [{
    vpc_id     = aws_vpc.private.id
    vpc_region = data.aws_region.current.name
  }]
  comment = "Internal services"
  tags = {
    Environment = "internal"
  }
}

# HTTPS Health Check without hosted zone
module "https_health_check" {
  source               = "../../"
  domain_name          = "monitored.waters.com"
  health_check_fqdn    = "api.monitored.waters.com"
  enable_https         = true
  health_check_path    = "/health"
  health_check_regions = ["us-west-2", "ap-southeast-1", "eu-west-1"]
}
```

---

## Module Structure

```
example/
├── main.tf
├── versions.tf
├── outputs.tf
├── README.md
└── ../../           # Route 53 module source
```

---

## Resources Deployed

| Name                  | Type                     | Description                              |
|-----------------------|--------------------------|------------------------------------------|
| `aws_route53_zone`    | Public + Private zones   | Hosted zones for public/private domains  |
| `aws_vpc`             | VPC                      | Used for private zone association        |
| `aws_route53_health_check` | Health Check        | Probes health of HTTPS/HTTP endpoints    |

---

## Best Practices

- Always enable health checks for critical endpoints to monitor their availability.
- Use private zones for internal services and associate them with relevant VPCs.
- Use consistent tagging for DNS resources to manage costs and ownership.
- Scope `vpc_associations` by region for multi-region deployments.

---
