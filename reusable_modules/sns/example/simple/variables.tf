# Provider Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Basic Topic Configuration
variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "notification-topic"
}

variable "display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = "Application Notifications"
}

variable "fifo_topic" {
  description = "Whether the topic is a FIFO topic"
  type        = bool
  default     = false
}

# Delivery Status Logging Variables
variable "lambda_success_feedback_role_arn" {
  description = "IAM role ARN for Lambda success feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Sample rate for Lambda success feedback"
  type        = number
  default     = null
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role ARN for Lambda failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "IAM role ARN for HTTP success feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Sample rate for HTTP success feedback"
  type        = number
  default     = null
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role ARN for HTTP failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "IAM role ARN for SQS success feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Sample rate for SQS success feedback"
  type        = number
  default     = null
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role ARN for SQS failure feedback"
  type        = string
  default     = null
}

variable "application_success_feedback_role_arn" {
  description = "IAM role ARN for application success feedback"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Sample rate for application success feedback"
  type        = number
  default     = null
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role ARN for application failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "IAM role ARN for Firehose success feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Sample rate for Firehose success feedback"
  type        = number
  default     = null
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role ARN for Firehose failure feedback"
  type        = string
  default     = null
}

# Policy Variables
variable "delivery_policy" {
  description = "Delivery policy JSON"
  type        = string
  default     = null
}

variable "data_protection_policy" {
  description = "Data protection policy JSON"
  type        = string
  default     = null
}

variable "topic_policy" {
  description = "Topic policy JSON"
  type        = string
  default     = null
}

variable "kms_master_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

# Subscription Variables
variable "admin_email" {
  description = "Admin email for notifications"
  type        = string
  default     = "admin@example.com"
}

variable "email_raw_delivery" {
  description = "Raw message delivery for email"
  type        = bool
  default     = null
}

variable "webhook_endpoint" {
  description = "Webhook endpoint URL"
  type        = string
  default     = "https://api.example.com/webhook"
}

variable "webhook_timeout" {
  description = "Webhook confirmation timeout"
  type        = number
  default     = null
}

variable "webhook_raw_delivery" {
  description = "Raw message delivery for webhook"
  type        = bool
  default     = null
}

variable "webhook_delivery_policy" {
  description = "Webhook delivery policy"
  type        = string
  default     = null
}

variable "lambda_function_arn" {
  description = "Lambda function ARN"
  type        = string
  default     = null
}

variable "lambda_redrive_policy" {
  description = "Lambda redrive policy"
  type        = string
  default     = null
}

variable "lambda_replay_policy" {
  description = "Lambda replay policy"
  type        = string
  default     = null
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN"
  type        = string
  default     = null
}

variable "sqs_raw_delivery" {
  description = "Raw message delivery for SQS"
  type        = bool
  default     = null
}

variable "sqs_filter_scope" {
  description = "SQS filter policy scope"
  type        = string
  default     = null
}

variable "sqs_redrive_policy" {
  description = "SQS redrive policy"
  type        = string
  default     = null
}

variable "sms_phone_number" {
  description = "SMS phone number"
  type        = string
  default     = null
}

variable "sms_delivery_policy" {
  description = "SMS delivery policy"
  type        = string
  default     = null
}

# Platform Application Variables
variable "ios_app_name" {
  description = "iOS app name"
  type        = string
  default     = null
}

variable "apns_certificate" {
  description = "APNS certificate"
  type        = string
  default     = null
  sensitive   = true
}

variable "apns_principal" {
  description = "APNS principal"
  type        = string
  default     = null
}

variable "ios_failure_topic_arn" {
  description = "iOS failure topic ARN"
  type        = string
  default     = null
}

variable "ios_created_topic_arn" {
  description = "iOS created topic ARN"
  type        = string
  default     = null
}

variable "ios_deleted_topic_arn" {
  description = "iOS deleted topic ARN"
  type        = string
  default     = null
}

variable "ios_updated_topic_arn" {
  description = "iOS updated topic ARN"
  type        = string
  default     = null
}

variable "ios_success_role_arn" {
  description = "iOS success role ARN"
  type        = string
  default     = null
}

variable "ios_failure_role_arn" {
  description = "iOS failure role ARN"
  type        = string
  default     = null
}

variable "ios_sample_rate" {
  description = "iOS sample rate"
  type        = number
  default     = null
}

variable "android_app_name" {
  description = "Android app name"
  type        = string
  default     = null
}

variable "fcm_server_key" {
  description = "FCM server key"
  type        = string
  default     = null
  sensitive   = true
}

variable "android_success_role_arn" {
  description = "Android success role ARN"
  type        = string
  default     = null
}

variable "android_failure_role_arn" {
  description = "Android failure role ARN"
  type        = string
  default     = null
}

variable "android_sample_rate" {
  description = "Android sample rate"
  type        = number
  default     = null
}

# FIFO Topic Variables
variable "fifo_topic_name" {
  description = "FIFO topic name"
  type        = string
  default     = "order-processing.fifo"
}

variable "fifo_display_name" {
  description = "FIFO topic display name"
  type        = string
  default     = "Order Processing"
}

variable "fifo_content_deduplication" {
  description = "FIFO content-based deduplication"
  type        = bool
  default     = true
}

variable "fifo_kms_key_id" {
  description = "FIFO topic KMS key ID"
  type        = string
  default     = null
}

variable "fifo_sqs_arn" {
  description = "FIFO SQS ARN"
  type        = string
  default     = null
}

variable "fifo_sqs_raw_delivery" {
  description = "FIFO SQS raw delivery"
  type        = bool
  default     = null
}

# Encrypted Topic Variables
variable "encrypted_topic_name" {
  description = "Encrypted topic name"
  type        = string
  default     = "encrypted-topic"
}

variable "encrypted_kms_key_id" {
  description = "Encrypted topic KMS key ID"
  type        = string
  default     = null
}

variable "encrypted_topic_policy" {
  description = "Encrypted topic policy"
  type        = string
  default     = null
}

# Tags
variable "tags" {
  description = "Tags for resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-example"
  }
}

variable "fifo_tags" {
  description = "Tags for FIFO resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-fifo-example"
    Type        = "fifo"
  }
}

variable "encrypted_tags" {
  description = "Tags for encrypted resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sns-encrypted-example"
    Type        = "encrypted"
  }
}