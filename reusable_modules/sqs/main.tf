# SQS Queue
resource "aws_sqs_queue" "this" {
  name                              = var.queue_name
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  deduplication_scope               = var.deduplication_scope
  fifo_throughput_limit             = var.fifo_throughput_limit
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled

  tags = var.tags
}

# Dead Letter Queue
resource "aws_sqs_queue" "dlq" {
  for_each = var.dlq_enabled ? { dlq = true } : {}

  name                              = local.dlq_name
  message_retention_seconds         = var.dlq_message_retention_seconds
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  max_message_size                  = var.max_message_size
  delay_seconds                     = var.delay_seconds
  receive_wait_time_seconds         = var.receive_wait_time_seconds
  fifo_queue                        = var.fifo_queue
  content_based_deduplication       = var.content_based_deduplication
  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_data_key_reuse_period_seconds
  deduplication_scope               = var.deduplication_scope
  fifo_throughput_limit             = var.fifo_throughput_limit
  sqs_managed_sse_enabled           = var.sqs_managed_sse_enabled

  tags = local.dlq_tags
}

# Local values for performance optimization
locals {
  has_policy_statements = length(var.queue_policy_statements) > 0
  create_policy = var.queue_policy != null || local.has_policy_statements
  
  # DLQ configuration
  dlq_name = var.fifo_queue ? replace(var.queue_name, ".fifo", "-dlq.fifo") : "${var.queue_name}-dlq"
  dlq_tags = merge(
    var.tags,
    {
      Name = local.dlq_name
      Type = "DeadLetterQueue"
    }
  )
}

# IAM Policy Document for Queue Policy
data "aws_iam_policy_document" "queue" {
  count = local.has_policy_statements ? 1 : 0

  dynamic "statement" {
    for_each = var.queue_policy_statements
    content {
      sid       = try(statement.value.sid, null)
      effect    = statement.value.effect
      actions   = statement.value.actions
      resources = [aws_sqs_queue.this.arn]

      dynamic "principals" {
        for_each = try(statement.value.principals, [])
        content {
          type        = principals.value.type
          identifiers = principals.value.identifiers
        }
      }

      dynamic "condition" {
        for_each = try(statement.value.conditions, [])
        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = [for v in condition.value.values : v if v != null]
        }
      }
    }
  }
}

# Queue Policy
resource "aws_sqs_queue_policy" "this" {
  count = local.create_policy ? 1 : 0

  queue_url = aws_sqs_queue.this.id
  policy    = var.queue_policy != null ? var.queue_policy : try(data.aws_iam_policy_document.queue[0].json, "{}")
}

# Redrive Policy for DLQ
resource "aws_sqs_queue_redrive_policy" "this" {
  for_each = var.dlq_enabled ? { redrive = true } : {}

  queue_url = aws_sqs_queue.this.id
  redrive_policy = jsonencode({
    deadLetterTargetArn = values(aws_sqs_queue.dlq)[0].arn
    maxReceiveCount     = var.dlq_max_receive_count
  })

  depends_on = [aws_sqs_queue.dlq]
}

# Redrive Allow Policy for DLQ
resource "aws_sqs_queue_redrive_allow_policy" "dlq" {
  for_each = var.dlq_enabled && var.dlq_redrive_allow_policy != null ? { policy = true } : {}

  queue_url = aws_sqs_queue.dlq["dlq"].id
  redrive_allow_policy = var.dlq_redrive_allow_policy
}