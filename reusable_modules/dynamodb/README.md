# DynamoDB Terraform Module

This module provisions **Amazon DynamoDB tables** with comprehensive configuration options including global secondary indexes, replicas, auto-scaling, encryption, and more.

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
- DynamoDB table creation with flexible configuration
- Global Secondary Indexes (GSI) and Local Secondary Indexes (LSI)
- **Global tables with optional cross-region replication**
- **Enhanced auto-scaling for tables and GSI**
- Server-side encryption with KMS
- Point-in-time recovery
- DynamoDB Streams
- TTL (Time To Live) configuration
- **Multiple table creation using for_each**
- Comprehensive tagging

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- IAM permissions for DynamoDB, KMS, Application Auto Scaling

---

## Usage Example

```hcl
module "users_table" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/dynamodb?ref=main"

  table_name   = "users-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "created_at"
  
  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
  
  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  stream_enabled                 = true
  stream_view_type              = "NEW_AND_OLD_IMAGES"
  
  # Optional: Enable global table with replicas
  global_table_enabled = true
  replica_regions = ["us-west-2", "eu-west-1"]
  replica_point_in_time_recovery_enabled = true
  
  tags = {
    Environment = "production"
    Team        = "backend"
  }
}
```

## Module Structure

```
modules/
└── dynamodb/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── README.md
    └── example/
        └── simple/
            ├── main.tf
            ├── variables.tf
            ├── versions.tf
            └── README.md
```

---

## Resources Used

| Resource                           | Purpose                                    |
|------------------------------------|--------------------------------------------|
| `aws_dynamodb_table`              | Creates DynamoDB tables                    |
| `aws_dynamodb_table_replica`       | Creates global table replicas              |
| `aws_appautoscaling_target`        | Sets up auto-scaling targets               |
| `aws_appautoscaling_policy`        | Configures auto-scaling policies           |

---

## Input Variables

| Name                              | Type   | Description                                    | Required |
|-----------------------------------|--------|------------------------------------------------|----------|
| `table_name`                     | string | Name of the DynamoDB table                     | Yes      |
| `billing_mode`                   | string | Billing mode (PAY_PER_REQUEST or PROVISIONED) | No       |
| `hash_key`                       | string | Hash key attribute name                        | Yes      |
| `range_key`                      | string | Range key attribute name                       | No       |
| `attributes`                     | list   | List of table attributes                       | Yes      |
| `global_secondary_indexes`       | list   | List of GSI configurations                     | No       |
| `local_secondary_indexes`        | list   | List of LSI configurations                     | No       |
| `server_side_encryption_enabled` | bool   | Enable server-side encryption                  | No       |
| `point_in_time_recovery_enabled` | bool   | Enable point-in-time recovery                  | No       |
| `stream_enabled`                 | bool   | Enable DynamoDB Streams                        | No       |
| `global_table_enabled`           | bool   | Enable global table functionality              | No       |
| `replica_regions`                | list   | List of regions for global table replicas     | No       |
| `replica_point_in_time_recovery_enabled` | bool | Enable PITR for replicas               | No       |
| `auto_scaling_enabled`           | bool   | Enable auto-scaling for table                  | No       |
| `gsi_auto_scaling_enabled`       | bool   | Enable auto-scaling for GSI                    | No       |
| `tags`                           | map    | Tags to apply to resources                     | No       |

---

## Outputs

| Name               | Description                           |
|--------------------|---------------------------------------|
| `table_name`       | Name of the created DynamoDB table   |
| `table_arn`        | ARN of the created DynamoDB table    |
| `table_id`         | ID of the created DynamoDB table     |
| `table_stream_arn` | Stream ARN of the table              |
| `replica_arns`     | ARNs of the table replicas           |
| `global_table_enabled` | Whether global table is enabled  |
| `replica_regions`  | List of replica regions              |

---

## Best Practices

- Use `PAY_PER_REQUEST` billing mode for unpredictable workloads
- Enable point-in-time recovery for production tables
- Use server-side encryption for sensitive data
- Configure auto-scaling for provisioned capacity tables
- Use global tables for multi-region applications
- Implement proper GSI design to avoid hot partitions
- Use TTL for automatic data expiration
- Tag resources for cost tracking and management

---