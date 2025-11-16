# Lambda Deployment Example (Using Reusable Module)

This is a working example of how to use the reusable Lambda Terraform module to deploy a Python Lambda function with:
- Custom environment variables
- SQS trigger
- IAM role and policies
- Lambda alias
- CloudWatch logging with retention

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Best Practices](#best-practices)

---

## Overview

This example uses a pre-packaged ZIP (lambda_function.zip) and deploys it as a Lambda function using the shared module. It demonstrates:

- Using local ZIP file via source_path
- Setting runtime to Python 3.12
- Passing environment variables
- Attaching an SQS event source trigger
- Creating a Lambda alias named "production"
- Enabling logging with a retention period of 30 days
- Attaching managed IAM policy AmazonS3ReadOnlyAccess


---

## Prerequisites

- Terraform CLI >= 1.12.2  
- AWS provider version >= 5.0  
- AWS credentials configured
- Lambda ZIP file at lambda_function.zip in the same folder

---

## Usage

```hcl
provider "aws" {
 region = "us-east-1"
}
module "lambda" {
 source          = "../../"
 function_name   = "example-lambda"
 handler         = "lambda_function.lambda_handler"
 runtime         = "python3.12"
 source_path     = "${path.module}/lambda_function.zip"
 environment_vars = {
   ENVIRONMENT = "test"
 }
 timeout              = 10
 memory_size          = 256
 log_retention_days   = 30
 alias_name           = "production"
 policy_arns = [
   "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
 ]
 triggers = [
   {
     event_source_arn  = "arn:aws:sqs:us-east-1:123456789012:my-queue"
     batch_size        = 10
     enabled           = true
     starting_position = "LATEST"
   }
 ]
}
```

---

## Module Structure

```
modules/
└── lambda/
    ├── main.tf
    ├── version.tf
    └── lambda_function.zip
```

---

## Resources Created

| Resource                                   | Purpose                                           |
|--------------------------------------------|---------------------------------------------------|
| `aws_lambda_function.example`              | Main Lambda function                              |
| `aws_cloudwatch_log_group`                 | Log group for the function                        |
| `aws_lambda_alias.production`              | Creates alias named "production"                  |
| `aws_iam_role.lambda`                      | IAM role for Lambda execution                     |
| `aws_iam_role_policy_attachment.*`         | Attaches basic execution policy                   |
| `aws_lambda_event_source_mapping.*`        | Creates SQS triggers                              |

---

## Best Practices

- Use .zip artifacts generated from CI/CD pipelines
- Set alias_name to maintain stable deployment references
- Attach only necessary policies to limit permissions
- Monitor Lambda performance with CloudWatch metrics
- Use batching and dead-letter queues for SQS triggers in production

---
