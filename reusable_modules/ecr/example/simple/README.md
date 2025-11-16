# ECR Terraform Module Example

This Terraform module example provisions **Amazon ECR repositories** with comprehensive features including lifecycle policies, IAM roles, image scanning, and support for both private and public repositories.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module demonstrates the creation and configuration of ECR repositories with the following features:

- **Private ECR repositories** with lifecycle policies and IAM roles
- **Public ECR repository** with catalog metadata
- Image vulnerability scanning on push
- Lifecycle policies for automatic image cleanup
- IAM roles for pull and push access
- Randomized repository naming using `random_id`
- Comprehensive tagging strategy

---

## Prerequisites

- Terraform CLI >= 1.0
- AWS Provider >= 5.0
- AWS CLI configured with proper permissions
- IAM permissions for ECR, IAM role creation

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Random suffix for unique repository names
resource "random_id" "suffix" {
  byte_length = 4
}

# Example: Private ECR repositories with lifecycle policy
module "ecr_private" {
  source = "../../"

  repository_names     = ["app-backend-${random_id.suffix.hex}", "app-frontend-${random_id.suffix.hex}"]
  repository_type      = "private"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
  encryption_type      = "AES256"
  force_delete         = true

  # Lifecycle policy to manage image retention
  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
          countType     = "imageCountMoreThan"
          countNumber   = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  # Create IAM roles for ECR access
  create_pull_role = true
  create_push_role = true

  tags = {
    Environment = "dev"
    Project     = "ecr-example"
    Terraform   = "true"
  }
}

# Example: Public ECR repository
module "ecr_public" {
  source = "../../"

  repository_names = ["public-demo-${random_id.suffix.hex}"]
  repository_type  = "public"
  force_delete     = true

  public_repository_catalog_data = {
    description       = "Demo public ECR repository"
    about_text        = "This is a demonstration of public ECR repository created with Terraform"
    usage_text        = "docker pull public.ecr.aws/your-registry/public-demo-${random_id.suffix.hex}:latest"
    operating_systems = ["Linux"]
    architectures     = ["x86-64", "ARM 64"]
  }

  tags = {
    Environment = "dev"
    Project     = "ecr-example"
    Terraform   = "true"
  }
}
```

---

## Module Structure

```
modules
└── ecr
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  ├── iam.tf
  └── README.md
  └── example
    └── simple
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      ├── versions.tf
      └── README.md
```

---

## Resources Created

| Resource                              | Description                                    |
|---------------------------------------|------------------------------------------------|
| `aws_ecr_repository`                  | Private ECR repositories                       |
| `aws_ecrpublic_repository`            | Public ECR repositories                        |
| `aws_ecr_lifecycle_policy`            | Lifecycle policies for image management        |
| `aws_iam_role`                        | IAM roles for ECR pull/push access            |
| `aws_iam_role_policy_attachment`      | Policy attachments for ECR permissions        |
| `random_id`                           | Random suffix for unique repository names      |

---

## Outputs

| Name                      | Description                           |
|---------------------------|---------------------------------------|
| `private_repository_urls` | URLs of the private ECR repositories  |
| `private_repository_arns` | ARNs of the private ECR repositories  |
| `public_repository_urls`  | URLs of the public ECR repositories   |
| `pull_role_arn`          | ARN of the ECR pull role              |
| `push_role_arn`          | ARN of the ECR push role              |

---

## Best Practices

- Use `random_id` to avoid repository name conflicts in global ECR namespace
- Enable `scan_on_push` for automatic vulnerability scanning
- Configure lifecycle policies to manage storage costs and cleanup old images
- Use `force_delete = true` cautiously, especially in production environments
- Create separate IAM roles for pull and push operations following least privilege principle
- Tag all resources consistently for better management and cost tracking
- Use private repositories for sensitive applications and public for open-source projects

---