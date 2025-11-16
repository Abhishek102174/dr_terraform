output "queue_id" {
  description = "ID of the SQS queue"
  value       = aws_sqs_queue.this.id
}

output "queue_arn" {
  description = "ARN of the SQS queue"
  value       = aws_sqs_queue.this.arn
}

output "queue_url" {
  description = "URL of the SQS queue"
  value       = aws_sqs_queue.this.url
}

output "queue_name" {
  description = "Name of the SQS queue"
  value       = aws_sqs_queue.this.name
}

# Dead Letter Queue Outputs
output "dlq_id" {
  description = "ID of the Dead Letter Queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq["dlq"].id : null
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq["dlq"].arn : null
}

output "dlq_url" {
  description = "URL of the Dead Letter Queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq["dlq"].url : null
}

output "dlq_name" {
  description = "Name of the Dead Letter Queue"
  value       = var.dlq_enabled ? aws_sqs_queue.dlq["dlq"].name : null
}

# Additional Queue Attributes
output "queue_fifo_queue" {
  description = "Whether the queue is FIFO"
  value       = aws_sqs_queue.this.fifo_queue
}

output "queue_content_based_deduplication" {
  description = "Whether content-based deduplication is enabled"
  value       = aws_sqs_queue.this.content_based_deduplication
}