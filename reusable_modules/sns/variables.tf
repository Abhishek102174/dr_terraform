# Basic Topic Configuration
variable "topic_name" {
  description = "Name of the SNS topic"
  type        = string
}

variable "display_name" {
  description = "Display name for the SNS topic"
  type        = string
  default     = null
}

variable "fifo_topic" {
  description = "Whether the topic is a FIFO topic"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO topics"
  type        = bool
  default     = false
}

# Encryption
variable "kms_master_key_id" {
  description = "KMS key ID for topic encryption"
  type        = string
  default     = null
}

# Delivery Policy
variable "delivery_policy" {
  description = "Delivery policy JSON for the SNS topic"
  type        = string
  default     = null
}

# Data Protection Policy
variable "data_protection_policy" {
  description = "Data protection policy JSON for the SNS topic"
  type        = string
  default     = null
}

# Delivery Status Logging
variable "application_success_feedback_role_arn" {
  description = "IAM role ARN for application success feedback"
  type        = string
  default     = null
}

variable "application_success_feedback_sample_rate" {
  description = "Sample rate for application success feedback (0-100)"
  type        = number
  default     = null
}

variable "application_failure_feedback_role_arn" {
  description = "IAM role ARN for application failure feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_role_arn" {
  description = "IAM role ARN for HTTP success feedback"
  type        = string
  default     = null
}

variable "http_success_feedback_sample_rate" {
  description = "Sample rate for HTTP success feedback (0-100)"
  type        = number
  default     = null
}

variable "http_failure_feedback_role_arn" {
  description = "IAM role ARN for HTTP failure feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_role_arn" {
  description = "IAM role ARN for Lambda success feedback"
  type        = string
  default     = null
}

variable "lambda_success_feedback_sample_rate" {
  description = "Sample rate for Lambda success feedback (0-100)"
  type        = number
  default     = null
}

variable "lambda_failure_feedback_role_arn" {
  description = "IAM role ARN for Lambda failure feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_role_arn" {
  description = "IAM role ARN for SQS success feedback"
  type        = string
  default     = null
}

variable "sqs_success_feedback_sample_rate" {
  description = "Sample rate for SQS success feedback (0-100)"
  type        = number
  default     = null
}

variable "sqs_failure_feedback_role_arn" {
  description = "IAM role ARN for SQS failure feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_role_arn" {
  description = "IAM role ARN for Firehose success feedback"
  type        = string
  default     = null
}

variable "firehose_success_feedback_sample_rate" {
  description = "Sample rate for Firehose success feedback (0-100)"
  type        = number
  default     = null
}

variable "firehose_failure_feedback_role_arn" {
  description = "IAM role ARN for Firehose failure feedback"
  type        = string
  default     = null
}

# Policy
variable "topic_policy" {
  description = "Topic policy JSON"
  type        = string
  default     = null
}

# Subscriptions
variable "subscriptions" {
  description = "Map of SNS topic subscriptions"
  type = map(object({
    protocol                        = string
    endpoint                        = string
    filter_policy                   = optional(string)
    filter_policy_scope            = optional(string)
    raw_message_delivery           = optional(bool)
    confirmation_timeout_in_minutes = optional(number)
    endpoint_auto_confirms         = optional(bool)
    delivery_policy                = optional(string)
    redrive_policy                 = optional(string)
    replay_policy                  = optional(string)
  }))
  default = {}
}

# Platform Applications
variable "platform_applications" {
  description = "Map of SNS platform applications"
  type = map(object({
    name                             = string
    platform                         = string
    platform_credential              = string
    platform_principal               = optional(string)
    event_delivery_failure_topic_arn = optional(string)
    event_endpoint_created_topic_arn = optional(string)
    event_endpoint_deleted_topic_arn = optional(string)
    event_endpoint_updated_topic_arn = optional(string)
    failure_feedback_role_arn        = optional(string)
    success_feedback_role_arn        = optional(string)
    success_feedback_sample_rate     = optional(number)
  }))
  default = {}
}

# Tags
variable "tags" {
  description = "Tags to apply to SNS resources"
  type        = map(string)
  default     = {}
}