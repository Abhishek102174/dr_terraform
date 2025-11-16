output "topic_id" {
  description = "ID of the SNS topic"
  value       = aws_sns_topic.this.id
}

output "topic_arn" {
  description = "ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "topic_name" {
  description = "Name of the SNS topic"
  value       = aws_sns_topic.this.name
}

output "topic_display_name" {
  description = "Display name of the SNS topic"
  value       = aws_sns_topic.this.display_name
}

output "subscription_arns" {
  description = "ARNs of the SNS topic subscriptions"
  value       = { for k, v in aws_sns_topic_subscription.this : k => v.arn }
}

output "platform_application_arns" {
  description = "ARNs of the SNS platform applications"
  value       = { for k, v in aws_sns_platform_application.this : k => v.arn }
}

output "topic_owner" {
  description = "AWS account ID of the SNS topic owner"
  value       = aws_sns_topic.this.owner
}

output "topic_beginning_archive_time" {
  description = "The oldest timestamp at which a FIFO topic subscriber can start a replay"
  value       = aws_sns_topic.this.beginning_archive_time
}