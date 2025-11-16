# SNS Terraform Module

This module creates AWS SNS topics with comprehensive features including subscriptions, delivery status logging, platform applications, and data protection policies.

## Features

- **Topic Types**: Standard and FIFO topics with content-based deduplication
- **Subscriptions**: Multiple protocols (SQS, Lambda, Email, HTTP/HTTPS, SMS) with filtering
- **Delivery Status Logging**: Track delivery success/failure for all protocols
- **Platform Applications**: Mobile push notifications (APNS, GCM, etc.)
- **Data Protection**: PII detection and redaction policies
- **Security**: KMS encryption and custom topic policies
- **Advanced Features**: Redrive policies, replay policies, delivery policies

## Usage

### Basic Topic with Subscriptions

```hcl
module "notification_topic" {
  source = "./modules/sns"

  topic_name   = "notification-topic"
  display_name = "Application Notifications"

  subscriptions = {
    email_admin = {
      protocol = "email"
      endpoint = "admin@example.com"
      filter_policy = jsonencode({
        event_type = ["error", "warning"]
      })
    }
    lambda_processor = {
      protocol = "lambda"
      endpoint = var.lambda_function_arn
      raw_message_delivery = true
    }
  }

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### FIFO Topic with Delivery Status Logging

```hcl
module "order_topic" {
  source = "./modules/sns"

  topic_name                  = "order-processing.fifo"
  fifo_topic                  = true
  content_based_deduplication = true

  # Delivery status logging
  lambda_success_feedback_role_arn    = var.sns_delivery_role_arn
  lambda_success_feedback_sample_rate = 100
  lambda_failure_feedback_role_arn    = var.sns_delivery_role_arn

  tags = {
    Environment = "production"
    Type        = "order-processing"
  }
}
```

### Mobile Push Notifications

```hcl
module "mobile_notifications" {
  source = "./modules/sns"

  topic_name = var.mobile_topic_name

  platform_applications = {
    ios_app = {
      name                = var.ios_app_name
      platform            = var.ios_platform
      platform_credential = var.apns_certificate
      success_feedback_role_arn = var.sns_platform_role_arn
      failure_feedback_role_arn = var.sns_platform_role_arn
    }
    android_app = {
      name                = var.android_app_name
      platform            = var.android_platform
      platform_credential = var.fcm_server_key
      success_feedback_role_arn = var.sns_platform_role_arn
      failure_feedback_role_arn = var.sns_platform_role_arn
    }
  }

  tags = {
    Environment = "production"
    Type        = "mobile-push"
  }
}
```

## Requirements

| Name | Version |
|------|---------| 
| terraform | >= 1.12.2 |
| aws | >= 5.40.0 |

## Resources Created

- `aws_sns_topic` - SNS topic
- `aws_sns_topic_policy` - Topic access policy (optional)
- `aws_sns_topic_subscription` - Topic subscriptions (optional)
- `aws_sns_topic_data_protection_policy` - Data protection policy (optional)
- `aws_sns_platform_application` - Mobile platform applications (optional)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| topic_name | Name of the SNS topic | `string` | n/a | yes |
| display_name | Display name for the SNS topic | `string` | `null` | no |
| fifo_topic | Whether the topic is a FIFO topic | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO topics | `bool` | `false` | no |
| kms_master_key_id | KMS key ID for topic encryption | `string` | `null` | no |
| delivery_policy | Delivery policy JSON for the SNS topic | `string` | `null` | no |
| data_protection_policy | Data protection policy JSON for the SNS topic | `string` | `null` | no |
| topic_policy | Topic policy JSON | `string` | `null` | no |
| subscriptions | Map of SNS topic subscriptions | `map(object)` | `{}` | no |
| platform_applications | Map of SNS platform applications | `map(object)` | `{}` | no |
| *_feedback_role_arn | IAM role ARNs for delivery status logging | `string` | `null` | no |
| *_feedback_sample_rate | Sample rates for delivery status logging (0-100) | `number` | `null` | no |
| tags | Tags to apply to SNS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| topic_id | ID of the SNS topic |
| topic_arn | ARN of the SNS topic |
| topic_name | Name of the SNS topic |
| topic_display_name | Display name of the SNS topic |
| topic_owner | AWS account ID of the SNS topic owner |
| topic_beginning_archive_time | The oldest timestamp for FIFO topic replay |
| subscription_arns | ARNs of the SNS topic subscriptions |
| platform_application_arns | ARNs of the SNS platform applications |

## Subscription Configuration

Each subscription supports:

- **protocol**: `email`, `email-json`, `sqs`, `lambda`, `http`, `https`, `sms`, `application`
- **endpoint**: Target endpoint for the subscription
- **filter_policy**: JSON filter policy for message filtering
- **raw_message_delivery**: Deliver raw message without JSON wrapping
- **redrive_policy**: Dead letter queue configuration
- **replay_policy**: Message replay configuration

## Platform Applications

Supported platforms:
- **APNS**: Apple Push Notification Service
- **APNS_SANDBOX**: Apple Push Notification Service (Sandbox)
- **GCM**: Google Cloud Messaging (Firebase)
- **ADM**: Amazon Device Messaging
- **BAIDU**: Baidu Cloud Push
- **MPNS**: Microsoft Push Notification Service
- **WNS**: Windows Push Notification Service

## Examples

See the [examples](./example/) directory for complete usage examples.