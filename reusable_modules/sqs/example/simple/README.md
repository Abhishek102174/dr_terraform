# SQS Example with Multiple Queue Types

This example demonstrates provisioning of **SQS queues** for different use cases including standard queues with Dead Letter Queues, FIFO queues for ordered processing, and simple notification queues. It uses the reusable SQS module with features like DLQ configuration, FIFO ordering, and content-based deduplication.

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

- A standard SQS queue with Dead Letter Queue for reliable message processing.
- A FIFO queue with content-based deduplication for ordered processing.
- A simple notification queue with default settings.
- Comprehensive tagging for resource management.
- Different visibility timeouts and retention periods based on use case.

---

## Resources Created

| Resource                    | Description                           |
|-----------------------------|---------------------------------------|
| `aws_sqs_queue` (processing)| Standard queue for background jobs    |
| `aws_sqs_queue` (processing-dlq) | Dead Letter Queue for failed messages |
| `aws_sqs_queue` (order)     | FIFO queue for ordered processing     |
| `aws_sqs_queue` (notification) | Simple queue for notifications     |
| `aws_sqs_queue_redrive_policy` | DLQ redrive configuration          |

---

## Features

### Processing Queue
- **Type**: Standard
- **Visibility Timeout**: 60 seconds
- **Message Retention**: 7 days
- **DLQ**: Enabled (3 max receives)
- **Use Case**: Background job processing

### Order Processing Queue
- **Type**: FIFO
- **Visibility Timeout**: 30 seconds
- **Message Retention**: 14 days (default)
- **DLQ**: Disabled
- **Features**: Content-based deduplication
- **Use Case**: Order processing requiring sequence

### Notification Queue
- **Type**: Standard
- **Settings**: All defaults
- **Use Case**: Simple notifications

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Standard SQS Queue with DLQ
module "processing_queue" {
  source = "../../"

  queue_name                 = "processing-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800  # 7 days
  dlq_enabled               = true
  dlq_max_receive_count     = 3

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-example"
    Type        = "processing"
  }
}

# FIFO Queue for ordered processing
module "order_queue" {
  source = "../../"

  queue_name                  = "order-processing.fifo"
  visibility_timeout_seconds  = 30
  fifo_queue                  = true
  content_based_deduplication = true
  dlq_enabled                 = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-example"
    Type        = "order-processing"
  }
}

# Simple notification queue
module "notification_queue" {
  source = "../../"

  queue_name = "notification-queue"

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-example"
    Type        = "notification"
  }
}
```

---

## Best Practices

- Use Dead Letter Queues for critical message processing to handle failures gracefully.
- Configure appropriate visibility timeouts based on your processing time requirements.
- Use FIFO queues only when message ordering is essential due to lower throughput.
- Enable content-based deduplication for FIFO queues to prevent duplicate processing.
- Tag resources consistently for better management and cost tracking.
- Set message retention periods based on your business requirements and compliance needs.

---