# MemoryDB Terraform Module Example

This Terraform module example provisions **Amazon MemoryDB for Redis** clusters with comprehensive features including custom parameter groups, ACL configuration, user management, and automated backup settings.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module demonstrates the creation and configuration of MemoryDB clusters with the following features:

- **MemoryDB cluster** with configurable shards and replicas
- **Custom parameter group** with Redis configuration parameters
- **ACL and user management** with password authentication
- **Subnet group** for network isolation
- **TLS encryption** enabled by default
- **Automated backups** with configurable retention
- **Randomized cluster naming** using `random_id`
- **Comprehensive tagging** strategy

---

## Prerequisites

- Terraform CLI >= 1.0
- AWS Provider >= 5.0
- Random Provider >= 3.0
- AWS CLI configured with proper permissions
- **Existing VPC with subnets** (minimum 2 subnets in different AZs)
- **Security groups** configured for Redis traffic (port 6379)
- IAM permissions for MemoryDB cluster creation

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Random suffix for unique cluster names
resource "random_id" "suffix" {
  byte_length = 4
}

# Example: MemoryDB cluster with custom configuration
module "memorydb_cluster" {
  source = "../../"

  cluster_name        = "example-cluster-${random_id.suffix.hex}"
  cluster_description = "Example MemoryDB cluster for testing"
  
  # Network Configuration (user must provide existing subnet IDs and security group IDs)
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]

  # Cluster Configuration
  node_type                = "db.t4g.small"
  num_shards               = 1
  num_replicas_per_shard   = 1
  engine_version           = "7.0"
  tls_enabled              = true

  # Parameter Group
  create_parameter_group = true
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]

  # ACL and Users
  create_acl = true
  users = {
    "app-user" = {
      access_string = "on ~* &* +@all"
      authentication_mode = {
        type      = "password"
        passwords = ["password123!"]
      }
    }
  }

  tags = {
    Environment = "example"
    Service     = "cache"
    Purpose     = "memorydb-testing"
  }
}
```

---

## Module Structure

```
modules
└── memorydb
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  └── README.md
  └── example
    └── simple
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      ├── provider.tf
      ├── versions.tf
      └── README.md
```

---

## Resources Created

| Resource                              | Description                                    |
|---------------------------------------|------------------------------------------------|
| `aws_memorydb_cluster`                | MemoryDB cluster with Redis engine            |
| `aws_memorydb_subnet_group`           | Subnet group for cluster network isolation    |
| `aws_memorydb_parameter_group`        | Parameter group for Redis configuration       |
| `aws_memorydb_acl`                    | Access Control List for user permissions      |
| `aws_memorydb_user`                   | Users with authentication and access control  |
| `aws_memorydb_snapshot`               | Optional cluster snapshots                     |
| `random_id`                           | Random suffix for unique cluster names        |

---

## Outputs

| Name                          | Description                           |
|-------------------------------|---------------------------------------|
| `memorydb_cluster_arn`        | ARN of the MemoryDB cluster          |
| `memorydb_cluster_endpoint`   | Cluster endpoint for MemoryDB        |
| `memorydb_cluster_port`       | Port of the MemoryDB cluster         |
| `memorydb_subnet_group_name`  | Name of the MemoryDB subnet group    |
| `memorydb_parameter_group_name` | Name of the MemoryDB parameter group |
| `memorydb_acl_name`           | Name of the MemoryDB ACL              |
| `memorydb_user_names`         | Names of the MemoryDB users          |

---

## Best Practices

- Use `random_id` to avoid cluster name conflicts in the AWS region
- **Provide actual subnet IDs and security group IDs** - the example uses placeholder values
- Enable TLS encryption for data in transit security
- Configure appropriate parameter groups for your Redis workload requirements
- Use strong passwords and consider AWS Secrets Manager for production environments
- Set up proper backup retention policies based on your recovery requirements
- Use `force_delete = true` cautiously, especially in production environments
- Create dedicated security groups with minimal required access (port 6379)
- Tag all resources consistently for better management and cost tracking
- Consider using IAM authentication instead of password authentication for enhanced security

---