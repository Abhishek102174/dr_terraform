variable "domain_name" {
  description = "Domain name for the hosted zone"
  type        = string
}

variable "comment" {
  description = "Comment for the hosted zone"
  type        = string
  default     = "CloudEngineering"
}

variable "private_zone" {
  description = "Whether the hosted zone is private"
  type        = bool
  default     = false
}

variable "vpc_associations" {
  description = "List of VPCs to associate with private hosted zone"
  type = list(object({
    vpc_id     = string
    vpc_region = string
  }))
  default = []
  
  validation {
    condition     = (var.private_zone && length(var.vpc_associations) > 0) || (!var.private_zone && length(var.vpc_associations) == 0)
    error_message = "Private zones require at least one VPC association, and public zones should not have VPC associations."
  }
}

variable "health_check_fqdn" {
  description = "FQDN to monitor for health checks"
  type        = string
  default     = ""
}

variable "health_check_protocol" {
  description = "Protocol for health check (HTTP, HTTPS, TCP)"
  type        = string
  default     = "HTTP"
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 80
}

variable "health_check_regions" {
  description = "AWS regions to deploy health checks"
  type        = list(string)
  default     = ["us-east-1", "us-west-2"]
}

variable "health_check_path" {
  description = "Resource path for HTTP/HTTPS checks"
  type        = string
  default     = "/"
}

variable "enable_https" {
  description = "Enable HTTPS for health checks"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

variable "records" {
 description = "List of DNS records to create"
 type = list(object({
   name            = string       # Record name (can be subdomain or '@' for apex)
   type            = string       # Record type (A, CNAME, MX, etc.)
   ttl             = optional(number)
   records         = optional(list(string))  # List of record values
   set_identifier  = optional(string)        # For routing policies
   health_check_id = optional(string)        # Associate health check
   # Alias configuration
   alias = optional(object({
     name                   = string
     zone_id                = string
     evaluate_target_health = optional(bool, false)
   }))
   # Failover routing
   failover_routing_policy = optional(object({
     type = string # PRIMARY or SECONDARY
   }))
   # Weighted routing
   weighted_routing_policy = optional(object({
     weight = number
   }))
   # Latency routing
   latency_routing_policy = optional(object({
     region = string
   }))
 }))
 default = []
}
variable "record_default_ttl" {
 description = "Default TTL for records when not specified"
 type        = number
 default     = 300
}