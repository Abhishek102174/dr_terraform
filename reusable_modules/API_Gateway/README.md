# API Gateway Terraform Module

This Terraform module provisions an **Amazon API Gateway** (both REST v1 and HTTP/WebSocket ) along with optional components such as stages, custom domains, logging, and authorizers (Lambda or Cognito). The module is flexible and supports environment-specific customization.

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

## Overview

This module supports provisioning of:

- API Gateway v1 (REST) or v2 (HTTP/WebSocket)
- Multiple stages with optional auto-deployment
- Access logging to CloudWatch
- Custom domain name and stage mappings
- Lambda-based or Cognito-based authorizers
- Optional API Key generation
- IAM roles and policies for API Gateway logging

---

## Prerequisites

- Terraform CLI >= 1.3.0  
- AWS provider version >= 5.0  
- IAM permissions to create:
  - API Gateway resources
  - CloudWatch log groups
  - IAM roles and policies  
  - Lambda and Cognito (if using authorizers)  

---

## Usage

```hcl
module "api_gateway" {
  source = "git::https://github.com/your-org/it-web-terraform-modules.git//modules/API_Gateway"

  api_type         = "HTTP" # or "REST" or "WEBSOCKET"
  api_name         = "my-service-api"
  api_description  = "API for my service"
  region           = "us-east-1"
  stages           = ["dev", "prod"]
  enable_logging   = true

  domain_name      = "api.example.com"
  certificate_arn  = "arn:aws:acm:us-east-1:123456789012:certificate/abcde-12345"

  enable_api_key   = true

  authorizer_config = {
    type             = "LAMBDA" # or "COGNITO"
    lambda_arn       = "arn:aws:lambda:us-east-1:123456789012:function:custom-authorizer"
    identity_sources = ["$request.header.Authorization"]
    cognito_pool     = "us-east-1_ABCDefghi" # Only for Cognito authorizer
  }
}
```

---

## Module Structure

```
modules
└── API_Gateway
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── README.md
    └── examples
        └── simple
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── version.tf
            └── README.md
```

---

## Resources Used

| Resource                                  | Purpose                                      |
|-------------------------------------------|----------------------------------------------|
| `aws_api_gateway_rest_api`                | Creates REST API (v1)                        |
| `aws_apigatewayv2_api`                    | Creates HTTP/WebSocket API (v2)              |
| `aws_apigatewayv2_stage`                  | Creates stages for v2 API                    |
| `aws_apigatewayv2_domain_name`            | Sets up custom domain                        |
| `aws_apigatewayv2_api_mapping`            | Maps domain to stages                        |
| `aws_apigatewayv2_authorizer`             | Adds Lambda or Cognito authorizer            |
| `aws_api_gateway_api_key`                 | Creates API Key (optional)                   |
| `aws_cloudwatch_log_group`                | Stores API Gateway logs                      |
| `aws_iam_role`, `aws_iam_role_policy`     | IAM role and inline policy for logging       |
| `aws_iam_role_policy_attachment`          | Attaches managed logging policy to role      |

---

## Input Variables
  
| Name                   | Type   | Description                                                | Required |
|------------------------|--------|------------------------------------------------------------|----------|
| `api_type`             | string | Type of API: `"HTTP"`, `"WEBSOCKET"`, or `"REST"`          |    Yes   |
| `api_name`             | string | Name for the API                                           |    Yes   |
| `api_description`      | sting  | Description of the API                                     |    No    |
| `region`               | string | AWS region where API will be deployed                      |    Yes   |
| `stages`               | list   | List of stages (e.g., `["dev", "prod"]`)                   |    Yes   |
| `enable_logging`       | bool   | Enable CloudWatch logging for API Gateway                  |    No    |
| `enable_api_key`       | bool   | Whether to generate an API key                             |    No    |
| `domain_name`          | string | Custom domain name to map to API stages                    |    No    |
| `certificate_arn`      | string | ACM certificate ARN for custom domain                      |    Yes   |
| `authorizer_config`    | object | Configuration for authorizer (type, ARN, identity sources) |    Yes   |

> Example `authorizer_config`:
```hcl
authorizer_config = {
  type             = "LAMBDA" # or "COGNITO"
  lambda_arn       = "arn:aws:lambda:us-east-1:123456789012:function:custom-authorizer"
  identity_sources = ["$request.header.Authorization"]
  cognito_pool     = "us-east-1_ABCDefghi" # Required if using COGNITO
}
```

## Outputs

| Name                    | Description                                |
|-------------------------|--------------------------------------------|
| `api_id`                | ID of the created API Gateway              |
| `api_endpoint`          | URL of the deployed API                    |
| `custom_domain_name`    | Custom domain name (if configured)         |
| `api_key`               | API key value (if enabled)                 |
| `cloudwatch_log_group`  | Name of the CloudWatch log group (if enabled) |

---

## Best Practices

- Prefer **HTTP APIs (v2)** for better performance and lower cost unless a specific v1 feature is needed.
- Enable **CloudWatch logging** for observability and debugging.
- Use **Lambda authorizers** for flexible token validation or **Cognito** for fully managed user pools.
- Keep **API keys** protected and rotate them periodically.
- When using **custom domains**, ensure DNS records are updated to point to the API Gateway target.

---
