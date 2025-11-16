# Notification Topic Outputs
output "notification_topic_arn" {
  description = "ARN of the notification topic"
  value       = module.notification_topic.topic_arn
}

output "notification_topic_subscriptions" {
  description = "Subscription ARNs for notification topic"
  value       = module.notification_topic.subscription_arns
}

output "notification_platform_applications" {
  description = "Platform application ARNs"
  value       = module.notification_topic.platform_application_arns
}

# FIFO Topic Outputs
output "fifo_topic_arn" {
  description = "ARN of the FIFO topic"
  value       = module.fifo_topic.topic_arn
}

output "fifo_topic_beginning_archive_time" {
  description = "Beginning archive time for FIFO topic"
  value       = module.fifo_topic.topic_beginning_archive_time
}

# Encrypted Topic Outputs
output "encrypted_topic_arn" {
  description = "ARN of the encrypted topic"
  value       = module.encrypted_topic.topic_arn
}

output "encrypted_topic_owner" {
  description = "Owner of the encrypted topic"
  value       = module.encrypted_topic.topic_owner
}