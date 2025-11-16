#  Detailed S3 Bucket Terraform Module 

This module provisions an **Amazon S3 bucket** with enhanced configuration and optional features like server-side encryption, versioning, public access blocking, lifecycle rules, website hosting, logging, and Lambda notifications.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Used](#resources-used)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

##  Overview

This module supports:
- Multiple S3 buckets creation
- Versioning configuration
- Server-side encryption (SSE-S3 or SSE-KMS)
- Public access restrictions
- Lifecycle rules for transitions and expiration
- Website configuration (static site hosting)
- Event notifications to Lambda, SQS or SNS
- Access logging (to dedicated log bucket)
- Custom tags
- Custom Bucket Policy

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Version 5.40.0 or higher
- AWS CLI configured with proper permissions
- IAM permissions for S3, KMS, Lambda (for notification config)

---

##  Usage Example

```hcl
module "s3_bucket" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules/tree/v0.0.6"

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

```
## Module Structure

```
modules
└── S3
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  └── README.md
  └── examples
    └── simple
      ├── main.tf
      ├── variables.tf
      ├── versions.tf
      └──README.md
```

---

## Resources Used

| Resource                                             | Purpose                                   |
|------------------------------------------------------|-------------------------------------------|
| `aws_s3_bucket`                                      | Creates the S3 bucket                     |
| `aws_s3_bucket_versioning`                           | Enables versioning                        |
| `aws_s3_bucket_server_side_encryption_configuration` | Configures encryption (SSE)               |
| `aws_s3_bucket_public_access_block`                  | Blocks public access                      |
| `aws_s3_bucket_lifecycle_configuration`              | Manages lifecycle rules                   |
| `aws_s3_bucket_website_configuration`                | Enables static website hosting            |
| `aws_s3_bucket_notification`                         | Sets Lambda notifications for events      |
| `aws_s3_bucket` (log bucket)                         | Creates separate log bucket               |
| `aws_s3_bucket_logging`                              | Enables logging on main bucket            |
| `aws_s3_bucket_policy` (custom)                      | Creates custom policy for main bucket     |
---

## Input Variables

| Name                   | Type   | Description                                                | Required |
|------------------------|--------|------------------------------------------------------------|----------|
| `bucket_name`          | string | Name of the S3 bucket                                      |    Yes   |
| `tags`                 | map    | Tags to apply to the bucket                                |    Yes   |
| `force_destroy`        | bool   | Whether to forcefully destroy the bucket                   |    Yes   |
| `versioning_enabled`   | bool   | Enable bucket versioning                                   |    Yes   |
| `encryption_enabled`   | bool   | Enable server-side encryption                              |    Yes   |
| `sse_algorithm`        | string | Encryption algorithm (`aws:kms` or `AES256`)               |    Yes   |
| `kms_key_id`           | string | KMS Key ID if `aws:kms` is used                            |    No    |
| `bucket_key_enabled`   | bool   | Enable bucket key for SSE-KMS                              |    Yes   |
| `block_public_access`  | bool   | Block public access                                        |    Yes   |
| `lifecycle_rules`      | map    | Lifecycle rules for managing object storage                |    Yes   |
| `lambda_notifications` | map    | Lambda notification configuration                          |    No    |
| `logging_enabled`      | bool   | Enable S3 access logging                                   |    Yes   |
| `logging_prefix`       | string | Log file prefix path                                       |    No    |

---

##  Outputs

| Name                 | Description                                                                                  |
|----------------------|----------------------------------------------------------------------------------------------|
| `bucket_arn`         | The ARN of the created bucket, used to uniquly identify the S3 Bucket accros all of AWS      |
| `bucket_domain_name` | The domain name of the created bucket that can be used to access the bucket via the internet |
| `bucket_name`        | The name of the created S3 bucket                                                            |
| `website_endpoint`   | Provides the static website endpoint for the bucket                                          |
| `log_bucket_arns`    | ARN of the log bucket (if created)                                                           |
| `log_bucket_names`   | Name of the log bucket (if created)                                                          |
```
---

## Best Practices

- Always block public access unless explicitly required.
- Use `SSE-KMS` and `bucket_key_enabled` for secure and cost-effective encryption.
- Use lifecycle rules to optimize storage cost (e.g., transition to GLACIER).
- Enable logging to monitor access and activity.
- Separate log buckets are useful for isolation and permissions.
- Use `force_destroy = false` in production to prevent accidental data loss.

---