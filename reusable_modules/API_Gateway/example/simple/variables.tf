variable "region" {
  default = "us-east-1"
}
variable "custom_resources" {
  description = "Map of custom resources to create"
  type = map(object({
    parent_key = string
    path_part  = string
  }))
  default = {}
}