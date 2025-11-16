variable "tempfiles_expiration_days" {
  description = "Number of days before temporary files expire"
  type        = number
  default     = 30
}

variable "docs_transition_to_standard_ia_days" {
  description = "Number of days before documents transition to STANDARD_IA storage class"
  type        = number
  default     = 30
}

variable "docs_transition_to_glacier_days" {
  description = "Number of days before documents transition to GLACIER storage class"
  type        = number
  default     = 60
}
