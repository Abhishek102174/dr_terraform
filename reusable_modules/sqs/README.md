# SQS Terraform Module

This module creates AWS SQS queues with comprehensive features including Dead Letter Queues, advanced FIFO configurations, structured policies, and enhanced security options.

## Features

- **Queue Types**: Standard and FIFO queues with high-throughput options
- **Dead Letter Queue**: Automatic DLQ creation with redrive policies
- **Advanced FIFO**: Message group deduplication and throughput controls
- **Security**: KMS encryption and SQS-managed SSE
- **Policy Management**: Structured IAM policies and raw JSON support
- **Performance**: Long polling, message batching, and delay queues
- **Monitoring**: Enhanced queue attributes and comprehensive outputs

## Usage

### Standard Queue with DLQ

```hcl
module "processing_queue" {
  source = "./modules/sqs"

  queue_name                 = "processing-queue"
  visibility_timeout_seconds = 60
  message_retention_seconds  = 604800  # 7 days
  receive_wait_time_seconds  = 20      # Long polling
  
  # Dead Letter Queue
  dlq_enabled                   = true
  dlq_max_receive_count        = 3
  dlq_message_retention_seconds = 1209600  # 14 days
  
  # Encryption
  sqs_managed_sse_enabled = true

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### High-Throughput FIFO Queue

```hcl
module "order_queue" {
  source = "./modules/sqs"

  queue_name                  = "order-processing.fifo"
  fifo_queue                  = true
  content_based_deduplication = true
  deduplication_scope         = "messageGroup"
  fifo_throughput_limit       = "perMessageGroupId"
  
  # KMS encryption
  kms_master_key_id                 = "alias/sqs-key"
  kms_data_key_reuse_period_seconds = 300

  dlq_enabled = true

  tags = {
    Environment = "production"
    Type        = "order-processing"
  }
}
```

### Queue with Structured Policy

```hcl
module "notification_queue" {
  source = "./modules/sqs"

  queue_name = "notification-queue"

  queue_policy_statements = [
    {
      effect  = "Allow"
      actions = ["sqs:SendMessage"]
      principals = [
        {
          type        = "Service"
          identifiers = ["sns.amazonaws.com"]
        }
      ]
      conditions = [
        {
          test     = "ArnEquals"
          variable = "aws:SourceArn"
          values   = ["arn:aws:sns:us-west-2:123456789012:my-topic"]
        }
      ]
    }
  ]

  tags = {
    Environment = "production"
    Type        = "notification"
  }
}
```

## Requirements

| Name | Version |
|------|---------| 
| terraform | >= 1.12.2 |
| aws | >= 5.40.0 |

## Resources Created

- `aws_sqs_queue` - Main SQS queue
- `aws_sqs_queue` - Dead Letter Queue (optional)
- `aws_sqs_queue_policy` - Queue access policy (optional)
- `aws_sqs_queue_redrive_policy` - DLQ redrive configuration (optional)
- `aws_sqs_queue_redrive_allow_policy` - DLQ redrive permissions (optional)
- `data.aws_iam_policy_document` - Structured policy generation (optional)

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| queue_name | Name of the SQS queue | `string` | n/a | yes |
| visibility_timeout_seconds | Visibility timeout in seconds | `number` | `30` | no |
| message_retention_seconds | Message retention period in seconds | `number` | `1209600` | no |
| max_message_size | Maximum message size in bytes | `number` | `262144` | no |
| delay_seconds | Time in seconds that delivery of messages is delayed | `number` | `0` | no |
| receive_wait_time_seconds | Time for ReceiveMessage call to wait for a message | `number` | `0` | no |
| fifo_queue | Whether the queue is a FIFO queue | `bool` | `false` | no |
| content_based_deduplication | Enable content-based deduplication for FIFO queues | `bool` | `false` | no |
| deduplication_scope | Deduplication scope: `messageGroup` or `queue` | `string` | `null` | no |
| fifo_throughput_limit | FIFO throughput quota: `perQueue` or `perMessageGroupId` | `string` | `null` | no |
| kms_master_key_id | KMS key ID for queue encryption | `string` | `null` | no |
| kms_data_key_reuse_period_seconds | KMS data key reuse period | `number` | `300` | no |
| sqs_managed_sse_enabled | Enable SQS managed server-side encryption | `bool` | `true` | no |
| dlq_enabled | Enable Dead Letter Queue | `bool` | `false` | no |
| dlq_max_receive_count | Maximum receives before moving to DLQ | `number` | `3` | no |
| dlq_message_retention_seconds | Message retention period for DLQ | `number` | `1209600` | no |
| dlq_redrive_allow_policy | JSON policy to allow redrive from DLQ | `string` | `null` | no |
| queue_policy | Queue policy JSON | `string` | `null` | no |
| queue_policy_statements | List of IAM policy statements for structured policy | `list(object)` | `[]` | no |
| tags | Tags to apply to SQS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| queue_id | ID of the SQS queue |
| queue_arn | ARN of the SQS queue |
| queue_url | URL of the SQS queue |
| queue_name | Name of the SQS queue |
| queue_fifo_queue | Whether the queue is FIFO |
| queue_content_based_deduplication | Whether content-based deduplication is enabled |
| dlq_id | ID of the Dead Letter Queue |
| dlq_arn | ARN of the Dead Letter Queue |
| dlq_url | URL of the Dead Letter Queue |
| dlq_name | Name of the Dead Letter Queue |

## FIFO Queue Configuration

For high-throughput FIFO queues:

- **deduplication_scope**: 
  - `messageGroup`: Deduplication per message group
  - `queue`: Deduplication across entire queue
  
- **fifo_throughput_limit**:
  - `perQueue`: 300 TPS for entire queue
  - `perMessageGroupId`: 3000 TPS per message group ID

## Policy Configuration

Two approaches for queue policies:

1. **Raw JSON**: Use `queue_policy` variable
2. **Structured**: Use `queue_policy_statements` for Terraform-native policy definition

## Examples

See the [examples](./example/) directory for complete usage examples.