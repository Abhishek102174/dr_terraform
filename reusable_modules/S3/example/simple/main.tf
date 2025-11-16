provider "aws" {
  region = "us-east-1"
}
resource "random_id" "suffix" {
  byte_length = 4
}
module "s3_buckets" {
  source = "../../"
  buckets = {
    "web-assets" = {
      bucket_name         = "it-web-${random_id.suffix.hex}"
      tags                = { Environment = "Sandbox" }
      block_public_access = true
      sse_algorithm       = "aws:kms"
      versioning_enabled  = true
      force_destroy       = true
      bucket_key_enabled  = true
      encryption_enabled  = true
      logging_enabled     = true
      logging_prefix      = "access-logs/"
      lifecycle_rules = {
        tempfiles = {
          enabled         = true
          filter_prefix   = "temp/"
          expiration_days = var.tempfiles_expiration_days
        }
        docs = {
          enabled       = true
          filter_prefix = "documents/"
          transitions = [
            {
              days          = var.docs_transition_to_standard_ia_days
              storage_class = "STANDARD_IA"
            },
            {
              days          = var.docs_transition_to_glacier_days
              storage_class = "GLACIER"
            }
          ]
        }
      }
      custom_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Sid       = "AllowSSLRequestsOnly",
            Effect    = "Deny",
            Principal = "*",
            Action    = "s3:*",
            Resource = [
              "arn:aws:s3:::it-web-${random_id.suffix.hex}",
              "arn:aws:s3:::it-web-${random_id.suffix.hex}/*"
            ],
            Condition = {
              Bool = {
                "aws:SecureTransport" = "false"
              }
            }
          }
        ]
      })
    }
    # Add more buckets here as needed
    # "app-logs" = { ... }
  }
}

output "bucket_arns" {
 value = module.s3_buckets.bucket_arns
}
output "web_bucket_domain" {
 value = module.s3_buckets.bucket_domain_names["web-assets"]
}