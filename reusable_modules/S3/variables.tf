variable "buckets" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    region              = optional(string)
    bucket_name         = string
    bucket_prefix       = optional(string)
    tags                = optional(map(string), {})
    force_destroy       = optional(bool, false)
    versioning_enabled  = optional(bool, false)
    encryption_enabled  = optional(bool, true)
    sse_algorithm       = optional(string, "AES256")
    kms_key_id          = optional(string)
    bucket_key_enabled  = optional(bool, false)
    block_public_access = optional(bool, true)
    lifecycle_rules = optional(map(object({
      enabled         = bool
      expiration_days = optional(number)
      filter_prefix   = optional(string)
      transitions = optional(list(object({
        days          = number
        storage_class = string
      })), [])
    })), {})
    logging_enabled = optional(bool, false)
    logging_prefix  = optional(string, "log/")
    custom_policy   = optional(string)
    website = optional(object({
      index_document = string
      error_document = string
    }))
    lambda_notifications = optional(list(object({
      arn           = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    sns_notifications = optional(list(object({
      arn           = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
    sqs_notifications = optional(list(object({
      arn           = string
      events        = list(string)
      filter_prefix = optional(string)
      filter_suffix = optional(string)
    })), [])
  }))
  default = {}
}