# VPC Terraform Module

This module provisions **AWS VPC** with public and private subnets, internet gateway, NAT gateway, and routing configurations.

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
- VPC creation with custom CIDR block
- DNS hostnames and DNS support configuration
- Public and private subnet creation across multiple AZs
- Internet Gateway for public subnet internet access (optional)
- NAT Gateway for private subnet outbound internet access (optional)
- Route tables and associations for proper traffic routing
- DHCP Options Set for custom DNS configuration (optional)
- Transit Gateway with VPC attachments (optional)
- VPC Endpoints for Gateway and Interface types (optional)
- Comprehensive resource tagging

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- IAM permissions for VPC, Subnet, IGW, NAT Gateway, and Route Table resources

---

## Usage Example

```hcl
module "vpc" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/vpc?ref=main"

  name       = "my-vpc"
  cidr_block = "10.0.0.0/16"

  # DNS settings (enabled by default)
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Optional: Enable internet connectivity
  create_igw         = true
  create_nat_gateway = true

  public_subnets = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  ]

  private_subnets = [
    {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1b"
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
└── vpc/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    └── README.md
```

---

## Resources Used

| Resource                              | Purpose                                    |
|---------------------------------------|--------------------------------------------|
| `aws_vpc`                             | Creates the VPC                           |
| `aws_internet_gateway`                | Provides internet access for public subnets (optional) |
| `aws_subnet`                          | Creates public and private subnets       |
| `aws_eip`                             | Elastic IP for NAT Gateway (optional)    |
| `aws_nat_gateway`                     | Provides outbound internet for private subnets (optional) |
| `aws_route_table`                     | Creates routing tables                    |
| `aws_route_table_association`         | Associates subnets with route tables     |
| `aws_vpc_dhcp_options`                | Custom DHCP options (optional)           |
| `aws_vpc_dhcp_options_association`    | Associates DHCP options with VPC (optional) |
| `aws_ec2_transit_gateway`             | Transit Gateway for inter-VPC connectivity (optional) |
| `aws_ec2_transit_gateway_vpc_attachment` | Attaches VPC to Transit Gateway (optional) |
| `aws_ec2_transit_gateway_route_table` | Transit Gateway route table (optional)   |
| `aws_vpc_endpoint`                    | VPC endpoints for AWS services (optional) |

---

## Input Variables

### Core Variables
| Name                  | Type   | Description                              | Required | Default |
|-----------------------|--------|------------------------------------------|----------|---------|
| `name`                | string | Name of the VPC                         | Yes      | -       |
| `cidr_block`          | string | CIDR block for the VPC                  | Yes      | -       |
| `enable_dns_hostnames`| bool   | Enable DNS hostnames in the VPC        | No       | true    |
| `enable_dns_support`  | bool   | Enable DNS support in the VPC          | No       | true    |
| `public_subnets`      | list   | List of public subnet configurations    | No       | []      |
| `private_subnets`     | list   | List of private subnet configurations   | No       | []      |
| `tags`                | map    | Tags to apply to all resources          | No       | {}      |

### Optional Infrastructure
| Name                  | Type   | Description                              | Required | Default |
|-----------------------|--------|------------------------------------------|----------|---------|
| `create_igw`          | bool   | Create Internet Gateway                 | No       | false   |
| `create_nat_gateway`  | bool   | Create NAT Gateway for private subnets  | No       | false   |
| `create_dhcp_options` | bool   | Create DHCP options set                 | No       | false   |
| `create_tgw`          | bool   | Create Transit Gateway                  | No       | false   |
| `create_tgw_route_table` | bool | Create Transit Gateway route table      | No       | false   |

### Subnet Configuration

Each subnet in `public_subnets` and `private_subnets` supports:

| Field              | Type   | Description                    | Required |
|--------------------|--------|--------------------------------|----------|
| `cidr_block`       | string | CIDR block for the subnet     | Yes      |
| `availability_zone`| string | Availability zone for subnet  | Yes      |

---

## Outputs

### Core Outputs
| Name                     | Description                           |
|--------------------------|---------------------------------------|
| `vpc_id`                 | ID of the created VPC                |
| `vpc_arn`                | ARN of the created VPC               |
| `vpc_cidr_block`         | CIDR block of the VPC                |
| `public_subnet_ids`      | List of public subnet IDs            |
| `private_subnet_ids`     | List of private subnet IDs           |
| `public_subnets`         | Detailed public subnet information   |
| `private_subnets`        | Detailed private subnet information  |

### Optional Infrastructure Outputs
| Name                          | Description                           |
|-------------------------------|---------------------------------------|
| `internet_gateway_id`         | ID of the Internet Gateway (if created) |
| `nat_gateway_ids`             | List of NAT Gateway IDs (if created) |
| `public_route_table_id`       | ID of the public route table (if IGW created) |
| `private_route_table_ids`     | List of private route table IDs (if NAT created) |
| `dhcp_options_id`             | ID of DHCP options set (if created)  |
| `transit_gateway_id`          | ID of Transit Gateway (if created)   |
| `transit_gateway_arn`         | ARN of Transit Gateway (if created)  |
| `transit_gateway_attachment_id` | ID of TGW VPC attachment (if created) |
| `transit_gateway_route_table_id` | ID of TGW route table (if created) |
| `vpc_endpoint_gateway_ids`    | IDs of Gateway VPC endpoints (if created) |
| `vpc_endpoint_interface_ids`  | IDs of Interface VPC endpoints (if created) |

---

## Best Practices

- Use appropriate CIDR block sizing for your needs
- Distribute subnets across multiple availability zones for high availability
- Use private subnets for application and database tiers
- Use public subnets only for resources that need direct internet access
- Enable DNS hostnames and support for proper service discovery
- Tag all resources consistently for better organization and cost tracking
- Consider using VPC endpoints for AWS services to reduce NAT Gateway costs
- Plan your IP address space carefully to avoid conflicts
- Use separate route tables for different subnet tiers when needed
- Monitor NAT Gateway usage and costs

---