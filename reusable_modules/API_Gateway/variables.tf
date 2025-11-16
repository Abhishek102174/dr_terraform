variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "api_type" {
  description = "API type (REST/HTTP/WEBSOCKET)"
  type        = string
  default     = "REST"
}

variable "api_description" {
  description = "Description of the API Gateway"
  type        = string
  default     = "Managed by Terraform"
}

variable "stages" {
  description = "List of deployment stages"
  type        = list(string)
  default     = ["dev"]
}

variable "auto_deploy" {
  description = "Enable automatic deployment for stages"
  type        = bool
  default     = true
}

variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = null
}

variable "certificate_arn" {
  description = "ACM certificate ARN for custom domain"
  type        = string
  default     = null
}

variable "domain_endpoint_type" {
  description = "Domain endpoint type (REGIONAL/EDGE)"
  type        = string
  default     = "REGIONAL"
}

variable "domain_security_policy" {
  description = "Security policy for custom domain"
  type        = string
  default     = "TLS_1_2"
}

variable "authorizer_config" {
  description = "Authorizer configuration"
  type = object({
    type                              = string
    lambda_arn                        = optional(string)
    cognito_pool                      = optional(string)
    identity_sources                  = optional(list(string))
    lambda_authorizer_type            = optional(string, "REQUEST")
    lambda_authorizer_name            = optional(string, "lambda-authorizer")
    lambda_payload_format_version     = optional(string, "2.0")
    cognito_authorizer_type           = optional(string, "JWT")
    cognito_authorizer_name           = optional(string, "cognito-authorizer")
  })
  default = null
}

variable "enable_api_key" {
  description = "Enable API key and usage plan"
  type        = bool
  default     = false
}

variable "api_key_name_suffix" {
  description = "Suffix for API key name"
  type        = string
  default     = "-key"
}

variable "enable_logging" {
  description = "Enable CloudWatch logging"
  type        = bool
  default     = true
}

variable "log_group_name_format" {
  description = "Format for CloudWatch log group name"
  type        = string
  default     = "/aws/apigateway/{api_name}"
}

variable "log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "access_log_format" {
  description = "Access log format for API Gateway"
  type        = string
  default     = "$context.identity.sourceIp - $context.identity.caller - $context.identity.user [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
}

variable "logging_role_name_suffix" {
  description = "Suffix for logging IAM role name"
  type        = string
  default     = "-logging-role"
}

variable "logging_policy_name_suffix" {
  description = "Suffix for logging IAM policy name"
  type        = string
  default     = "-logging-policy"
}

# Enhanced integrations variable to support both REST and HTTP/WebSocket APIs
variable "integrations" {
  description = "List of integrations for the API"
  type = list(object({
    # Common fields
    integration_type    = string
    integration_method  = optional(string, "POST")
    integration_uri     = string
    authorization_type  = optional(string, "NONE")
    
    # For API Gateway v2 (HTTP/WebSocket)
    route_key              = optional(string)
    payload_format_version = optional(string, "2.0")
    
    # For API Gateway v1 (REST)
    resource_path      = optional(string)
    http_method        = optional(string, "POST")
    path_part          = optional(string)
    api_key_required   = optional(bool, false)
  }))
  default = []
  
  validation {
    condition = alltrue([
      for integration in var.integrations : 
      (integration.route_key != null) || (integration.resource_path != null && integration.http_method != null)
    ])
    error_message = "Each integration must have either 'route_key' (for HTTP/WebSocket) or both 'resource_path' and 'http_method' (for REST)."
  }
}

# REST API specific variables
variable "rest_api_binary_media_types" {
  description = "Binary media types for REST API"
  type        = list(string)
  default     = []
}

variable "rest_api_minimum_compression_size" {
  description = "Minimum response size to compress for REST API"
  type        = number
  default     = null
}
