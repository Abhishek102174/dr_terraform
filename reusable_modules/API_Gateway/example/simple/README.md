# Lambda + API Gateway Example (Terraform)

This example demonstrates how to deploy two AWS Lambda functions using Terraform:  
- A **Lambda Authorizer** for custom authorization logic  
- A **Backend Lambda** that serves API requests via API Gateway  

The setup includes IAM roles, permissions, route integrations, and CloudWatch logging.

---

## Table of Contents

- [Overview](#overview)  
- [Prerequisites](#prerequisites)  
- [Usage](#usage)  
- [Project Structure](#project-structure)  
- [Resources Created](#resources-created)  
- [Best Practices](#best-practices)

---

## Overview

This example provisions:

- A Lambda Authorizer function zipped from `lambdas/` directory
- A backend Lambda function zipped from `lambdas/backend.py`
- IAM execution roles and policies for both functions
- API Gateway v2 (HTTP) with two routes: `/` and `/hello`
- Lambda integrations and permissions
- Automatic linkage to a reusable API Gateway module

---

## Prerequisites

- Terraform CLI >= 1.3.0  
- AWS Provider >= 5.0  
- IAM permissions to create Lambda, IAM, and API Gateway resources  
- A `lambdas/` directory with `authorizer.py` and `backend.py`

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source          = "../../"
  api_name        = "example-api"
  api_type        = "HTTP"
  stages          = ["dev", "prod"]
  domain_name     = null
  certificate_arn = null

  authorizer_config = {
    type             = "LAMBDA"
    lambda_arn       = aws_lambda_function.authorizer.arn
    identity_sources = ["$request.header.Authorization"]
  }

  enable_api_key = true
  enable_logging = true
}
```

Make sure to place:
- `authorizer.py` in `lambdas/` folder
- `backend.py` in `lambdas/` folder

Terraform will package these into ZIP files.

---

## Project Structure

```
example/
├── main.tf
├── variables.tf
├── version.tf
├── lambdas/
│   ├── authorizer.py
│   └── backend.py
└── outputs.tf
```

---

## Resources Created

| Resource                             | Purpose                                           |
|--------------------------------------|---------------------------------------------------|
| `aws_iam_role.lambda_exec`           | IAM role for both Lambda functions                |
| `aws_lambda_function.authorizer`     | Custom Lambda authorizer                          |
| `aws_lambda_function.backend`        | Backend logic handler                             |
| `aws_lambda_permission.api_gw*`      | Permission for API Gateway to invoke Lambda       |
| `aws_apigatewayv2_route.*`           | Routes: `/` and `/hello`                          |
| `aws_apigatewayv2_integration.*`     | Integration of backend Lambda with HTTP API       |
| `data.archive_file.*`                | Packages Lambda code into ZIP files               |

---

## Best Practices

- Use distinct IAM roles for authorizer and backend for better isolation (if needed).
- Follow the least privilege principle for IAM policies.
- Always validate tokens inside the Lambda authorizer.
- Monitor both Lambda and API Gateway logs via CloudWatch.
- Use environment variables to pass secrets securely to Lambda.

---
