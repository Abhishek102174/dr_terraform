# Processing Queue Outputs
output "processing_queue_url" {
  description = "URL of the processing queue"
  value       = module.processing_queue.queue_url
}

output "processing_queue_arn" {
  description = "ARN of the processing queue"
  value       = module.processing_queue.queue_arn
}

output "processing_dlq_url" {
  description = "URL of the processing queue DLQ"
  value       = module.processing_queue.dlq_url
}

output "processing_dlq_arn" {
  description = "ARN of the processing queue DLQ"
  value       = module.processing_queue.dlq_arn
}

# FIFO Queue Outputs
output "fifo_queue_url" {
  description = "URL of the FIFO queue"
  value       = module.fifo_queue.queue_url
}

output "fifo_queue_arn" {
  description = "ARN of the FIFO queue"
  value       = module.fifo_queue.queue_arn
}

output "fifo_queue_fifo" {
  description = "Whether FIFO queue is FIFO"
  value       = module.fifo_queue.queue_fifo_queue
}

# Policy Queue Outputs
output "policy_queue_url" {
  description = "URL of the policy queue"
  value       = module.policy_queue.queue_url
}

output "policy_queue_arn" {
  description = "ARN of the policy queue"
  value       = module.policy_queue.queue_arn
}

# Encrypted Queue Outputs
output "encrypted_queue_url" {
  description = "URL of the encrypted queue"
  value       = module.encrypted_queue.queue_url
}

output "encrypted_queue_arn" {
  description = "ARN of the encrypted queue"
  value       = module.encrypted_queue.queue_arn
}

# Delay Queue Outputs
output "delay_queue_url" {
  description = "URL of the delay queue"
  value       = module.delay_queue.queue_url
}

# Polling Queue Outputs
output "polling_queue_url" {
  description = "URL of the polling queue"
  value       = module.polling_queue.queue_url
}