variable "function_name" {
  description = "Lambda function name"
  type        = string
}
variable "handler" {
  description = "Lambda handler entrypoint"
  type        = string
  default     = "index.handler"
}
variable "runtime" {
  description = "Lambda runtime environment"
  type        = string
  default     = "python3.12"
}
variable "source_path" {
  description = "Path to local source code/ZIP file"
  type        = string
  default     = null
}
variable "s3_bucket" {
  description = "S3 bucket for code deployment"
  type        = string
  default     = null
}
variable "s3_key" {
  description = "S3 object key for code"
  type        = string
  default     = null
}
variable "environment_vars" {
  description = "Environment variables"
  type        = map(string)
  default     = {}
}
variable "layers" {
  description = "ARNs of existing Lambda layers to attach"
  type        = list(string)
  default     = []
}
variable "timeout" {
  description = "Function timeout in seconds"
  type        = number
  default     = 3
}
variable "memory_size" {
  description = "Memory allocation in MB"
  type        = number
  default     = 128
}
variable "reserved_concurrency" {
  description = "Concurrency limit"
  type        = number
  default     = -1
}
variable "log_retention_days" {
  description = "CloudWatch log retention period"
  type        = number
  default     = 7
}
variable "policy_arns" {
  description = "Custom IAM policy ARNs"
  type        = list(string)
  default     = []
}
variable "triggers" {
  description = "Event source mappings configuration"
  type = list(object({
    event_source_arn  = string
    batch_size        = optional(number, 10)
    enabled           = optional(bool, true)
    starting_position = optional(string) # Only for Kinesis/DynamoDB
  }))
  default = []
}
variable "alias_name" {
  description = "Alias for published version"
  type        = string
  default     = "live"
}
variable "s3_triggers" {
  description = "S3 bucket event triggers"
  type = map(object({
    bucket_arn    = string
    events        = list(string)
    filter_prefix = optional(string)
    filter_suffix = optional(string)
  }))
  default = {}
}
variable "enable_snap_start" {
  description = "Enable SnapStart for Lambda function"
  type        = bool
  default     = false
}
variable "auto_publish" {
  description = "Automatically publish new versions on code changes"
  type        = bool
  default     = false
}
variable "aws_region" {
  description = "AWS region"
  type        = string
}

# Simplified Lambda Layer variables
variable "lambda_layers" {
  description = "Lambda layers to create"
  type = map(object({
    filename            = optional(string)
    s3_bucket          = optional(string)
    s3_key             = optional(string)
    layer_name         = string
    description        = optional(string, "Lambda layer")
    compatible_runtimes = list(string)
    skip_destroy       = optional(bool, false)
  }))
  default = {}
}

variable "layer_permissions" {
  description = "Permissions for Lambda layers"
  type = map(object({
    layer_name      = string
    principal       = string
    action          = optional(string, "lambda:GetLayerVersion")
    organization_id = optional(string)
  }))
  default = {}
}
variable "inline_policy_json" {
  description = "Optional IAM inline policy JSON to attach to the Lambda execution role"
  type        = string
  default     = null
}
