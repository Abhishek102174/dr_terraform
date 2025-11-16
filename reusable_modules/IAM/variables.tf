variable "namespace" {
  type        = string
  description = "ID element. Usually an abbreviation of your organization name, e.g. 'eg' or 'cp', to help ensure generated IDs are globally unique"
  default     = ""
}

variable "environment" {
  type        = string
  description = "ID element. Usually used for region e.g. 'uw2', 'us-west-2', OR role 'prod', 'staging', 'dev', 'UAT'"
  default     = ""
}

variable "stage" {
  type        = string
  description = "ID element. Usually used to indicate role, e.g. 'prod', 'staging', 'source', 'build', 'test', 'deploy', 'release'"
  default     = ""
}

variable "name" {
  type        = string
  description = "ID element. Usually the component or solution name, e.g. 'app' or 'jenkins'"
  default     = ""
}

variable "attributes" {
  type        = list(string)
  description = "ID element. Additional attributes (e.g. `workers` or `cluster`) to add to `id`"
  default     = []
}

variable "delimiter" {
  type        = string
  description = "Delimiter to be used between ID elements"
  default     = "-"
}

variable "tags" {
  type        = map(string)
  description = "Additional tags (e.g. `{'BusinessUnit': 'XYZ'}`)"
  default     = {}
}

# IAM Users
variable "users" {
  type = map(object({
    path          = optional(string, "/")
    force_destroy = optional(bool, false)
    tags          = optional(map(string), {})
  }))
  description = "Map of IAM users to create"
  default     = {}
}

# IAM Groups
variable "groups" {
  type = map(object({
    path = optional(string, "/")
  }))
  description = "Map of IAM groups to create"
  default     = {}
}

variable "group_memberships" {
  type = map(object({
    group = string
    users = list(string)
  }))
  description = "Map of group memberships"
  default     = {}
}

# IAM Roles
variable "roles" {
  type = map(object({
    assume_role_policy    = string
    description          = optional(string)
    force_detach_policies = optional(bool, false)
    max_session_duration = optional(number, 3600)
    path                 = optional(string, "/")
    permissions_boundary = optional(string)
    tags                 = optional(map(string), {})
  }))
  description = "Map of IAM roles to create"
  default     = {}
}

# Managed Policies
variable "managed_policies" {
  type = map(object({
    description = optional(string)
    policy      = string
    path        = optional(string, "/")
    tags        = optional(map(string), {})
  }))
  description = "Map of managed IAM policies to create"
  default     = {}
}

# Policy Attachments
variable "user_policy_attachments" {
  type = map(object({
    user       = string
    policy_arn = string
  }))
  description = "Map of user policy attachments"
  default     = {}
}

variable "group_policy_attachments" {
  type = map(object({
    group      = string
    policy_arn = string
  }))
  description = "Map of group policy attachments"
  default     = {}
}

variable "role_policy_attachments" {
  type = map(object({
    role       = string
    policy_arn = string
  }))
  description = "Map of role policy attachments"
  default     = {}
}

# Inline Policies
variable "user_inline_policies" {
  type = map(object({
    user   = string
    policy = string
  }))
  description = "Map of inline policies for users"
  default     = {}
}

variable "group_inline_policies" {
  type = map(object({
    group  = string
    policy = string
  }))
  description = "Map of inline policies for groups"
  default     = {}
}

variable "role_inline_policies" {
  type = map(object({
    role   = string
    policy = string
  }))
  description = "Map of inline policies for roles"
  default     = {}
}

# Federated Identity Providers
variable "saml_identity_providers" {
  type = map(object({
    saml_metadata_document = string
    tags                   = optional(map(string), {})
  }))
  description = "Map of SAML identity providers"
  default     = {}
}

variable "oidc_identity_providers" {
  type = map(object({
    url             = string
    client_id_list  = list(string)
    thumbprint_list = list(string)
    tags            = optional(map(string), {})
  }))
  description = "Map of OIDC identity providers"
  default     = {}
}
