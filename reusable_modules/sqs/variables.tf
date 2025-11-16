# Basic Queue Configuration
variable "queue_name" {
  description = "Name of the SQS queue"
  type        = string
}

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the queue in seconds"
  type        = number
  default     = 30
}

variable "message_retention_seconds" {
  description = "Message retention period in seconds (default: 1209600 = 14 days)"
  type        = number
  default     = 1209600  # 14 days
}

variable "max_message_size" {
  description = "Maximum message size in bytes (default: 262144 = 256 KB)"
  type        = number
  default     = 262144
}

variable "delay_seconds" {
  description = "Time in seconds that delivery of messages is delayed"
  type        = number
  default     = 0
}

variable "receive_wait_time_seconds" {
  description = "Time for which a ReceiveMessage call will wait for a message to arrive"
  type        = number
  default     = 0
}

variable "fifo_queue" {
  description = "Whether the queue is a FIFO queue"
  type        = bool
  default     = false
}

variable "content_based_deduplication" {
  description = "Enable content-based deduplication for FIFO queues"
  type        = bool
  default     = false
}

# Encryption
variable "kms_master_key_id" {
  description = "KMS key ID for queue encryption"
  type        = string
  default     = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "Length of time for which Amazon SQS can reuse a data key"
  type        = number
  default     = 300
}

variable "sqs_managed_sse_enabled" {
  description = "Enable SQS managed server-side encryption"
  type        = bool
  default     = true
}

# FIFO Configuration
variable "deduplication_scope" {
  description = "Specifies whether message deduplication occurs at the message group or queue level"
  type        = string
  default     = null
  validation {
    condition     = var.deduplication_scope == null || contains(["messageGroup", "queue"], var.deduplication_scope)
    error_message = "Deduplication scope must be either 'messageGroup' or 'queue'."
  }
}

variable "fifo_throughput_limit" {
  description = "Specifies whether the FIFO queue throughput quota applies to the entire queue or per message group"
  type        = string
  default     = null
  validation {
    condition     = var.fifo_throughput_limit == null || contains(["perQueue", "perMessageGroupId"], var.fifo_throughput_limit)
    error_message = "FIFO throughput limit must be either 'perQueue' or 'perMessageGroupId'."
  }
}

# Dead Letter Queue
variable "dlq_enabled" {
  description = "Enable Dead Letter Queue"
  type        = bool
  default     = false
}

variable "dlq_max_receive_count" {
  description = "Maximum receives before moving to DLQ"
  type        = number
  default     = 3
  validation {
    condition     = var.dlq_max_receive_count > 0
    error_message = "DLQ max receive count must be greater than 0."
  }
}

variable "dlq_message_retention_seconds" {
  description = "Message retention period for DLQ in seconds (default: 1209600 = 14 days)"
  type        = number
  default     = 1209600
}

variable "dlq_redrive_allow_policy" {
  description = "JSON policy to allow redrive from DLQ"
  type        = string
  default     = null
}

# Policy
variable "queue_policy" {
  description = "Queue policy JSON"
  type        = string
  default     = null
}

variable "queue_policy_statements" {
  description = "List of IAM policy statements for the queue policy"
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

# Tags
variable "tags" {
  description = "Tags to apply to SQS resources"
  type        = map(string)
  default     = {}
}