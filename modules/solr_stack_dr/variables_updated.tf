# Remove or comment out this variable since you're using existing key pair
# variable "solr_public_key" {
#   description = "Public key content for Solr cluster SSH access"
#   type        = string
#   default     = ""
# }

# Keep only the key_name variable
variable "key_name" {
  description = "EC2 Key Pair name for Solr instances (must exist in AWS)"
  type        = string
}
