# Standard Queue
module "processing_queue" {
  source = "../../"

  queue_name                        = var.queue_name
  visibility_timeout_seconds        = var.visibility_timeout_seconds
  message_retention_seconds         = var.message_retention_seconds
  dlq_enabled                      = var.dlq_enabled
  dlq_max_receive_count           = var.dlq_max_receive_count
  sqs_managed_sse_enabled         = var.sqs_managed_sse_enabled
  tags                            = var.tags
}

# FIFO Queue
module "fifo_queue" {
  source = "../../"

  queue_name                  = var.fifo_queue_name
  fifo_queue                 = true
  content_based_deduplication = var.fifo_content_deduplication
  deduplication_scope        = var.fifo_deduplication_scope
  fifo_throughput_limit      = var.fifo_throughput_limit
  dlq_enabled               = var.fifo_dlq_enabled
  tags                      = var.fifo_tags
}

# Policy Queue
module "policy_queue" {
  source = "../../"

  queue_name = var.policy_queue_name
  queue_policy_statements = [
    {
      sid     = "AllowSNSPublish"
      effect  = "Allow"
      actions = ["sqs:SendMessage", "sqs:SendMessageBatch"]
      principals = [{
        type        = "Service"
        identifiers = ["sns.amazonaws.com"]
      }]
      conditions = [{
        test     = "ArnEquals"
        variable = "aws:SourceArn"
        values   = [var.sns_topic_arn]
      }]
    }
  ]
  tags = var.policy_tags
}

# Encrypted queue
module "encrypted_queue" {
  source = "../../"

  queue_name                        = var.encrypted_queue_name
  kms_master_key_id                = var.encrypted_kms_key_id
  kms_data_key_reuse_period_seconds = var.encrypted_kms_reuse_period
  sqs_managed_sse_enabled          = var.encrypted_sse_enabled
  
  dlq_enabled = var.encrypted_dlq_enabled
  queue_policy = var.encrypted_queue_policy

  tags = var.encrypted_tags
}

# Delay queue
module "delay_queue" {
  source = "../../"

  queue_name    = var.delay_queue_name
  delay_seconds = var.delay_queue_seconds
  
  tags = var.delay_tags
}

# Long polling queue
module "polling_queue" {
  source = "../../"

  queue_name                = var.polling_queue_name
  receive_wait_time_seconds = var.polling_wait_time
  
  tags = var.polling_tags
}