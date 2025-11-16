# Reusable AWS Lambda Terraform Module

This Terraform module provisions a reusable and configurable AWS Lambda function along with:
- CloudWatch log group
- Optional function alias
- IAM execution role with custom policy attachments
- Optional event source mappings for triggers (e.g., DynamoDB, SQS, Kinesis)

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module supports:

- Lambda deployment using S3 bucket + key or direct ZIP file path
- Custom handler, runtime, layers, environment variables
- IAM execution role with optional managed policy ARNs
- Event source mappings for services like DynamoDB, SQS, and Kinesis
- Optional Lambda alias support
- Custom memory, timeout, and concurrency settings

---

## Prerequisites

- Terraform CLI >= 1.12.2  
- AWS provider version >= 5.0  
- IAM permissions for Lambda, IAM, and CloudWatch

---

## Usage

```hcl
module "lambda_function" {
  source          = "git::https://github.com/your-org/it-web-terraform-modules.git//modules/lambda"

  function_name   = "my-backend"
  s3_bucket       = "my-lambda-artifacts"
  s3_key          = "backend.zip"
  handler         = "main.handler"
  runtime         = "python3.8"

  environment_vars = {
    ENV  = "dev"
    LOG  = "enabled"
  }

  memory_size     = 128
  timeout         = 10
  reserved_concurrency = 5
  log_retention_days   = 7

  alias_name      = "live"

  policy_arns     = [
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
  ]

  triggers = {
    trigger1 = {
      event_source_arn  = "arn:aws:sqs:us-east-1:123456789012:my-queue"
      enabled           = true
      batch_size        = 10
      starting_position = "LATEST"
    }
  }
}
```

---

## Module Structure

```
modules/
└── lambda/
    ├── main.tf
    ├── iam.tf
    ├── triggers.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

---

## Resources Created

| Resource                                   | Purpose                                           |
|--------------------------------------------|---------------------------------------------------|
| `aws_lambda_function`                      | Main Lambda function                              |
| `aws_cloudwatch_log_group`                 | Log group for the function                        |
| `aws_lambda_alias`                         | Optional alias (e.g., live/stage)                 |
| `aws_iam_role.lambda`                      | IAM role for Lambda execution                     |
| `aws_iam_role_policy_attachment.basic`     | Attaches basic execution policy                   |
| `aws_iam_role_policy_attachment.custom`    | Attaches user-defined policies                    |
| `aws_lambda_event_source_mapping`          | Creates event source mappings for triggers        |

---

## Input Variables

| Name                      | Type     | Description                                                  | Required |
|---------------------------|----------|--------------------------------------------------------------|----------|
| `function_name`           | string   | Name of the Lambda function                                  | Yes      |
| `s3_bucket`               | string   | S3 bucket for Lambda code artifact                           | No       |
| `s3_key`                  | string   | S3 key (object path) for Lambda code                         | No       |
| `source_path`             | string   | Path to local ZIP file for Lambda code                       | No       |
| `handler`                 | string   | Function entry point (e.g., `index.handler`)                 | Yes      |
| `runtime`                 | string   | Lambda runtime (`python3.8`, `nodejs18.x`, etc.)             | Yes      |
| `environment_vars`        | map      | Environment variables for Lambda                             | No       |
| `memory_size`             | number   | Memory (MB) for Lambda                                       | No       |
| `timeout`                 | number   | Timeout (seconds) for Lambda                                 | No       |
| `reserved_concurrency`    | number   | Reserved concurrency value                                   | No       |
| `alias_name`              | string   | Optional alias name                                          | No       |
| `log_retention_days`      | number   | CloudWatch log retention period                              | No       |
| `policy_arns`             | list     | List of IAM policy ARNs to attach to Lambda role             | No       |
| `triggers`                | map      | Optional event triggers (SQS, DynamoDB, etc.)                | No       |

---

## Outputs

| Name                | Description                                |
|---------------------|--------------------------------------------|
| `lambda_arn`        | ARN of the Lambda function                 |
| `lambda_name`       | Name of the Lambda function                |
| `lambda_role_arn`   | ARN of the IAM role for the Lambda         |
| `alias_arn`         | ARN of the Lambda alias (if created)       |

---

## Best Practices

- Prefer using S3 for larger Lambda artifacts and CI pipelines.
- Use versioning and aliases to safely promote Lambda versions.
- Grant only minimal required IAM permissions to the Lambda role.
- Set appropriate timeouts to prevent long-running costs.
- Attach CloudWatch alerts for function failures or throttles.

---
