# Provider Configuration
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Standard Queue Variables
variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
  default     = "processing-queue"
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout in seconds"
  type        = number
  default     = 60
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds"
  type        = number
  default     = 604800
}

variable "max_message_size" {
  description = "Maximum message size in bytes"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Delay seconds for message delivery"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Receive wait time for long polling"
  type        = number
  default     = 20
}

# DLQ Variables
variable "dlq_enabled" {
  description = "Enable Dead Letter Queue"
  type        = bool
  default     = true
}

variable "dlq_max_receive_count" {
  description = "Max receive count before DLQ"
  type        = number
  default     = 3
}

variable "dlq_message_retention_seconds" {
  description = "DLQ message retention seconds"
  type        = number
  default     = 1209600
}

variable "dlq_redrive_allow_policy" {
  description = "DLQ redrive allow policy"
  type        = string
  default     = null
}

# Encryption Variables
variable "kms_master_key_id" {
  description = "KMS key ID for encryption"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "KMS data key reuse period"
  type        = number
  default     = 300
}

variable "sqs_managed_sse_enabled" {
  description = "Enable SQS managed SSE"
  type        = bool
  default     = true
}

# Policy Variables
variable "queue_policy" {
  description = "Queue policy JSON"
  type        = string
  default     = null
}

variable "queue_policy_statements" {
  description = "Queue policy statements"
  type = list(object({
    sid    = optional(string)
    effect = string
    actions = list(string)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

# FIFO Queue Variables
variable "fifo_queue_name" {
  description = "FIFO queue name"
  type        = string
  default     = "order-processing.fifo"
}

variable "fifo_visibility_timeout" {
  description = "FIFO visibility timeout"
  type        = number
  default     = 30
}

variable "fifo_message_retention" {
  description = "FIFO message retention"
  type        = number
  default     = 1209600
}

variable "fifo_max_message_size" {
  description = "FIFO max message size"
  type        = number
  default     = 262144
}

variable "fifo_delay_seconds" {
  description = "FIFO delay seconds"
  type        = number
  default     = 0
}

variable "fifo_receive_wait_time" {
  description = "FIFO receive wait time"
  type        = number
  default     = 10
}

variable "fifo_content_deduplication" {
  description = "FIFO content-based deduplication"
  type        = bool
  default     = true
}

variable "fifo_deduplication_scope" {
  description = "FIFO deduplication scope"
  type        = string
  default     = "messageGroup"
}

variable "fifo_throughput_limit" {
  description = "FIFO throughput limit"
  type        = string
  default     = "perMessageGroupId"
}

variable "fifo_dlq_enabled" {
  description = "Enable FIFO DLQ"
  type        = bool
  default     = true
}

variable "fifo_dlq_max_receive_count" {
  description = "FIFO DLQ max receive count"
  type        = number
  default     = 5
}

variable "fifo_kms_key_id" {
  description = "FIFO KMS key ID"
  type        = string
  default     = null
}

variable "fifo_kms_reuse_period" {
  description = "FIFO KMS reuse period"
  type        = number
  default     = 300
}

variable "fifo_sse_enabled" {
  description = "FIFO SSE enabled"
  type        = bool
  default     = false
}

variable "fifo_queue_policy" {
  description = "FIFO queue policy"
  type        = string
  default     = null
}

variable "fifo_policy_statements" {
  description = "FIFO policy statements"
  type = list(object({
    sid    = optional(string)
    effect = string
    actions = list(string)
    principals = optional(list(object({
      type        = string
      identifiers = list(string)
    })), [])
    conditions = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  default = []
}

# Policy Queue Variables
variable "policy_queue_name" {
  description = "Policy queue name"
  type        = string
  default     = "policy-queue"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for policy"
  type        = string
  default     = null
}

variable "cross_account_principals" {
  description = "Cross-account principals"
  type        = list(string)
  default     = []
}

variable "cross_account_conditions" {
  description = "Cross-account conditions"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

# Encrypted Queue Variables
variable "encrypted_queue_name" {
  description = "Encrypted queue name"
  type        = string
  default     = "encrypted-queue"
}

variable "encrypted_kms_key_id" {
  description = "Encrypted queue KMS key ID"
  type        = string
  default     = null
}

variable "encrypted_kms_reuse_period" {
  description = "Encrypted queue KMS reuse period"
  type        = number
  default     = 300
}

variable "encrypted_sse_enabled" {
  description = "Encrypted queue SSE enabled"
  type        = bool
  default     = false
}

variable "encrypted_dlq_enabled" {
  description = "Encrypted queue DLQ enabled"
  type        = bool
  default     = false
}

variable "encrypted_queue_policy" {
  description = "Encrypted queue policy"
  type        = string
  default     = null
}

# Delay Queue Variables
variable "delay_queue_name" {
  description = "Delay queue name"
  type        = string
  default     = "delay-queue"
}

variable "delay_queue_seconds" {
  description = "Delay queue seconds"
  type        = number
  default     = 900
}

# Polling Queue Variables
variable "polling_queue_name" {
  description = "Polling queue name"
  type        = string
  default     = "polling-queue"
}

variable "polling_wait_time" {
  description = "Polling wait time"
  type        = number
  default     = 20
}

# Tags
variable "tags" {
  description = "Standard queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-example"
    Type        = "processing"
  }
}

variable "fifo_tags" {
  description = "FIFO queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-fifo-example"
    Type        = "fifo"
  }
}

variable "policy_tags" {
  description = "Policy queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-policy-example"
    Type        = "policy"
  }
}

variable "encrypted_tags" {
  description = "Encrypted queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-encrypted-example"
    Type        = "encrypted"
  }
}

variable "delay_tags" {
  description = "Delay queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-delay-example"
    Type        = "delay"
  }
}

variable "polling_tags" {
  description = "Polling queue tags"
  type        = map(string)
  default = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "sqs-polling-example"
    Type        = "polling"
  }
}