# DynamoDB Example

This example demonstrates provisioning of **DynamoDB tables** with different configurations using the reusable DynamoDB module. It showcases both pay-per-request and provisioned capacity modes with various features.

---

## Table of Contents

- [Overview](#overview)
- [Resources Created](#resources-created)
- [Features](#features)
- [Usage](#usage)
- [Best Practices](#best-practices)

---

## Overview

This configuration sets up:

- A **users table** with pay-per-request billing and DynamoDB Streams
- An **orders table** with provisioned capacity and auto-scaling
- Global Secondary Indexes (GSI) for both tables
- Server-side encryption and point-in-time recovery
- TTL configuration for the orders table
- Auto-scaling for both table and GSI capacity

---

## Resources Created

| Resource                      | Description                             |
|-------------------------------|-----------------------------------------|
| `aws_dynamodb_table`          | DynamoDB tables                         |
| `aws_appautoscaling_target`   | Auto-scaling targets for capacity       |
| `aws_appautoscaling_policy`   | Auto-scaling policies                   |

---

## Features

### Users Table
- **Billing Mode**: Pay-per-request
- **Keys**: Hash key (user_id), Range key (created_at)
- **GSI**: Email index for querying by email
- **Streams**: Enabled with NEW_AND_OLD_IMAGES
- **Encryption**: Server-side encryption enabled
- **PITR**: Point-in-time recovery enabled

### Orders Table
- **Billing Mode**: Provisioned capacity with auto-scaling
- **Keys**: Hash key (order_id), Range key (customer_id)
- **GSI**: Status index for querying by order status
- **Auto-scaling**: Enabled for both table and GSI
- **TTL**: Enabled with expires_at attribute
- **Encryption**: Server-side encryption enabled
- **PITR**: Point-in-time recovery enabled

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "users_table" {
  source = "../../"

  table_name   = "users-table-example"
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
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "dynamodb-example"
  }
}

module "orders_table" {
  source = "../../"

  table_name     = "orders-table-example"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "order_id"
  range_key      = "customer_id"
  
  attributes = [
    {
      name = "order_id"
      type = "S"
    },
    {
      name = "customer_id"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name            = "status-index"
      hash_key        = "status"
      range_key       = "customer_id"
      projection_type = "KEYS_ONLY"
      read_capacity   = 2
      write_capacity  = 2
    }
  ]
  
  auto_scaling_enabled              = true
  auto_scaling_read_min_capacity    = 2
  auto_scaling_read_max_capacity    = 20
  auto_scaling_write_min_capacity   = 2
  auto_scaling_write_max_capacity   = 20
  
  gsi_auto_scaling_enabled           = true
  gsi_auto_scaling_read_min_capacity = 1
  gsi_auto_scaling_read_max_capacity = 10
  gsi_auto_scaling_write_min_capacity = 1
  gsi_auto_scaling_write_max_capacity = 10
  
  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  ttl_enabled                    = true
  ttl_attribute_name             = "expires_at"
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "dynamodb-example"
  }
}
```

---

## Best Practices

- Use **PAY_PER_REQUEST** billing mode for unpredictable workloads
- Enable **point-in-time recovery** for production tables
- Use **server-side encryption** for sensitive data
- Configure **auto-scaling** for provisioned capacity tables
- Implement proper **GSI design** to avoid hot partitions
- Use **TTL** for automatic data expiration
- **Tag resources** for cost tracking and management
- Enable **DynamoDB Streams** for real-time data processing
- Use **KEYS_ONLY** projection for GSI when full item data isn't needed

---