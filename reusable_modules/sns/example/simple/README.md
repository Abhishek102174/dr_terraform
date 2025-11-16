# SNS Example with Multiple Topic Types

This example demonstrates provisioning of **SNS topics** for different use cases including standard topics with multiple subscriptions, FIFO topics for ordered processing, and simple alert topics. It uses the reusable SNS module with features like multiple subscription protocols, FIFO ordering, and content-based deduplication.

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

- A standard SNS topic with email and webhook subscriptions for notifications.
- A FIFO topic with content-based deduplication for ordered processing.
- A simple alert topic with SMS subscription.
- Comprehensive tagging for resource management.
- Different subscription protocols based on use case.

---

## Resources Created

| Resource                    | Description                           |
|-----------------------------|---------------------------------------|
| `aws_sns_topic` (notification)| Standard topic for app notifications |
| `aws_sns_topic` (order)     | FIFO topic for ordered processing     |
| `aws_sns_topic` (alert)     | Simple topic for alerts              |
| `aws_sns_topic_subscription` | Multiple subscription types          |

---

## Features

### Notification Topic
- **Type**: Standard
- **Subscriptions**: Email, HTTPS webhook
- **Use Case**: Application notifications

### Order Processing Topic
- **Type**: FIFO
- **Features**: Content-based deduplication
- **Use Case**: Order processing requiring sequence

### Alert Topic
- **Type**: Standard
- **Subscriptions**: SMS
- **Use Case**: Critical alerts

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Standard SNS Topic with multiple subscriptions
module "notification_topic" {
  source = "../../"

  topic_name   = "notification-topic"
  display_name = "Application Notifications"

  subscriptions = {
    email_admin = {
      protocol = "email"
      endpoint = "admin@example.com"
    }
    webhook = {
      protocol = "https"
      endpoint = "https://api.example.com/webhook"
      confirmation_timeout_in_minutes = 5
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-example"
    Type        = "notification"
  }
}

# FIFO SNS Topic for ordered processing
module "order_topic" {
  source = "../../"

  topic_name                  = "order-processing.fifo"
  display_name               = "Order Processing Notifications"
  fifo_topic                 = true
  content_based_deduplication = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-example"
    Type        = "order-processing"
  }
}

# Simple alert topic
module "alert_topic" {
  source = "../../"

  topic_name = "alert-topic"

  subscriptions = {
    sms_alert = {
      protocol = "sms"
      endpoint = "+1234567890"
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-example"
    Type        = "alert"
  }
}
```

---

## Best Practices

- Use appropriate subscription protocols based on your notification requirements.
- Configure confirmation timeouts for HTTP/HTTPS endpoints to handle delays.
- Use FIFO topics only when message ordering is essential due to lower throughput.
- Enable content-based deduplication for FIFO topics to prevent duplicate processing.
- Tag resources consistently for better management and cost tracking.
- Use filter policies to route messages to specific subscribers based on content.
- Consider using SQS subscriptions for reliable message processing with retry logic.

---