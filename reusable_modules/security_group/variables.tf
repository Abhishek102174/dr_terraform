# Basic Security Group Configuration
variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

# Ingress Rules
variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = []
}

# Egress Rules
variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks             = optional(list(string))
    ipv6_cidr_blocks        = optional(list(string))
    source_security_group_id = optional(string)
    self                    = optional(bool)
    description             = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

# Tags
variable "tags" {
  description = "Tags to apply to the security group"
  type        = map(string)
  default     = {}
}