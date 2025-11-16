# S3 Terraform Module example

This Terraform module example provisions a secure and configurable **Amazon S3 bucket** with features such as lifecycle rules, encryption, logging, versioning, public access control, and Lambda notifications.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Resources Used](#resources-used)
- [Best Practices](#best-practices)

---

##  Overview

This module demonstrates the creation and configuration of an S3 bucket with the following features:

- Randomized bucket naming using `random_uuid`
- Secure encryption (SSE-KMS)
- Logging enabled
- Object lifecycle rules
- Public access blocking
- Lambda event notifications for object uploads
- Versioning and force destroy options
- Static website hosting

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Version 5.40.0 or higher
- AWS CLI configured with proper permissions
- IAM permissions for S3, KMS, Lambda (for notification config)

---

## Usage

```hcl
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
```

---

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
      ├── versions.tf
      └──README.md
```

---

##  Input Variables

| Name                   | Type   | Description                                                | Required |
|------------------------|--------|------------------------------------------------------------|----------|
| `bucket_name`          | string | Name of the S3 bucket                                      |    Yes   |
| `tags`                 | map    | Tags to apply to the bucket                                |    Yes   |
| `force_destroy`        | bool   | Whether to forcefully destroy the bucket                   |    Yes   |
| `versioning_enabled`   | bool   | Enable bucket versioning                                   |    Yes   |
| `encryption_enabled`   | bool   | Enable server-side encryption                              |    Yes   |
| `sse_algorithm`        | string | Encryption algorithm (`aws:kms` or `AES256`)               |    Yes   |
| `bucket_key_enabled`   | bool   | Enable bucket key for SSE-KMS                              |    Yes   |
| `block_public_access`  | bool   | Block public access                                        |    Yes   |
| `lifecycle_rules`      | map    | Lifecycle rules for managing object storage                |    Yes   |
| `lambda_notifications` | map    | Lambda notification configuration                          |    No    |
| `logging_enabled`      | bool   | Enable S3 access logging                                   |    Yes   |
| `logging_prefix`       | string | Log file prefix path                                       |    Yes   |
| `static_website`       | bool   | Enable static website hosting                              |    Yes   |

---

##  Outputs

This module should define output variables like:

```hcl
output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

- Purpose: Uniquely identifies the S3 bucket across all of AWS.

- Format: arn:aws:s3:::<bucket-name>

- Use Case: Often used when granting IAM permissions or setting up resource policies, such as bucket policies, Lambda permissions, etc.

- Example:
arn:aws:s3:::Demo_Bucket-${random_uuid.bucket_name.result}


---

##  Resources Used

| Resource Type        | Purpose                                                        |
|----------------------|----------------------------------------------------------------|
| `provider "aws"`     | Specifies AWS as the provider                                  |
| `random_uuid`        | Generates unique UUID to ensure unique bucket naming           |
| `module "eg_1"`      | Calls reusable S3 bucket module with advanced configurations   |
| `output`             | Exports the S3 bucket ARN                                      |

---

## Best Practices

- Use `random_uuid` to avoid name conflicts in global S3 namespace.
- Always enable `block_public_access` unless explicitly needed.
- Use `SSE-KMS` for enhanced data security and compliance.
- Enable `versioning` and `logging` for audit and recovery purposes.
- Avoid hardcoding values — use environment-specific `.tfvars`.
- Configure `force_destroy` cautiously, especially in production.

---


##  Example `.tfvars`

```hcl
tempfiles_expiration_days            = 7
docs_transition_to_standard_ia_days = 45
docs_transition_to_glacier_days     = 120
```