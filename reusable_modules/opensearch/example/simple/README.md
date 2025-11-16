# OpenSearch Terraform Module Example

This Terraform module example provisions **Amazon OpenSearch Service** domains and **OpenSearch Serverless** collections with comprehensive features including VPC integration, security policies, logging configuration, and encryption settings.

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

This module demonstrates the creation and configuration of OpenSearch resources with the following features:

- **OpenSearch Serverless collection** with VPC private access and automatic scaling
- **Basic OpenSearch domain** for development with single-node configuration
- **Production OpenSearch domain** with multi-AZ deployment and advanced security
- **VPC integration** with private endpoints for secure access
- **Security policies** for encryption, network access, and data access control
- **CloudWatch logging** with configurable retention periods
- **AWS-owned encryption** for cost-effective security
- **Comprehensive tagging** strategy

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- **Existing VPC with subnets** (minimum 2 subnets in different AZs for production)
- **Security groups** configured for HTTPS traffic (port 443)
- IAM permissions for OpenSearch service creation

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

# Example: OpenSearch Serverless Collection with VPC
module "opensearch_serverless" {
  source = "../../"

  # Serverless deployment
  deployment_type = "serverless"
  domain_name     = "example-search-collection"
  collection_type = "SEARCH"
  description     = "Example serverless collection with VPC access"
  
  # Security policies
  create_encryption_policy   = true
  use_aws_owned_key         = true
  create_network_policy     = true
  allow_from_public         = false
  create_data_access_policy = true
  
  # VPC configuration (user must provide existing VPC and subnet IDs)
  vpc_enabled        = true
  create_vpc_endpoint = true
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  # Data access principals
  data_access_principals = [
    "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  ]
  
  # Logging
  audit_logs_enabled         = true
  error_logs_enabled         = true
  create_log_resource_policy = true
  log_retention_days         = 14
  
  # KMS - using AWS-owned keys
  create_kms_key = false
  
  tags = {
    Environment = "example"
    Service     = "search"
    Type        = "serverless"
    Purpose     = "opensearch-testing"
  }
}

# Example: Basic OpenSearch Domain for Development
module "opensearch_domain" {
  source = "../../"

  # Provisioned deployment
  deployment_type = "provisioned"
  domain_name     = "example-search-domain"
  engine_version  = "OpenSearch_2.3"
  
  # Cluster configuration
  instance_type  = "t3.small.search"
  instance_count = 1
  
  # Storage
  volume_type = "gp3"
  volume_size = 20
  
  # Network - VPC deployment (user must provide existing VPC and subnet IDs)
  vpc_enabled        = true
  subnet_ids         = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  
  # Security
  encrypt_at_rest          = true
  node_to_node_encryption = true
  enforce_https           = true
  
  # Logging
  audit_logs_enabled         = true
  create_log_resource_policy = true
  log_retention_days         = 7
  
  # KMS - using AWS-owned keys
  create_kms_key = false
  
  tags = {
    Environment = "example"
    Service     = "search"
    Type        = "development"
    Purpose     = "opensearch-testing"
  }
}
```

---

## Module Structure

```
modules
└── opensearch
  ├── main.tf
  ├── variables.tf
  ├── outputs.tf
  ├── versions.tf
  └── README.md
  └── example
    └── simple
      ├── main.tf
      ├── variables.tf
      ├── outputs.tf
      ├── provider.tf
      ├── versions.tf
      └── README.md
```

---

## Resources Created

| Resource                                    | Description                                    |
|---------------------------------------------|------------------------------------------------|
| `aws_opensearchserverless_collection`       | OpenSearch Serverless collection              |
| `aws_opensearchserverless_security_policy`  | Encryption, network, and data access policies |
| `aws_opensearchserverless_vpc_endpoint`     | VPC endpoint for serverless private access    |
| `aws_opensearch_domain`                     | OpenSearch domain with configurable cluster   |
| `aws_cloudwatch_log_group`                 | CloudWatch log groups for audit and error logs|
| `aws_cloudwatch_log_resource_policy`        | CloudWatch log resource policy                |
| `aws_kms_key`                              | Custom KMS key for encryption (optional)      |
| `aws_kms_alias`                            | KMS key alias (optional)                      |

---

## Outputs

| Name                              | Description                                   |
|-----------------------------------|-----------------------------------------------|
| `serverless_collection_arn`       | ARN of the OpenSearch Serverless collection  |
| `serverless_collection_endpoint`   | Endpoint of the OpenSearch Serverless collection |
| `serverless_dashboard_endpoint`    | Dashboard endpoint of the serverless collection |
| `domain_arn`                      | ARN of the OpenSearch domain                 |
| `domain_endpoint`                 | Endpoint of the OpenSearch domain            |
| `dashboard_endpoint`              | Dashboard endpoint of the OpenSearch domain  |
| `vpc_endpoint_id`                 | ID of the VPC endpoint                       |
| `log_group_names`                 | Names of the CloudWatch log groups           |

---

## Best Practices

- **Provide actual VPC and subnet IDs** - the example uses placeholder values
- Use **VPC deployment** for network isolation and security
- Enable **AWS-owned encryption** for cost-effective security
- Configure **appropriate log retention** based on compliance requirements
- Use **specific IAM principals** instead of wildcards for data access
- Set up **proper security groups** with minimal required access (HTTPS port 443)
- **Choose serverless** for variable workloads and **provisioned** for predictable workloads
- Enable **comprehensive logging** for troubleshooting and compliance
- Use **consistent tagging** for better resource management and cost tracking
- Consider **VPC endpoints** for private API access without internet gateway
- **Plan subnet placement** across multiple availability zones for high availability
- Use **AWS Secrets Manager** for storing sensitive credentials in production
- Monitor **CloudWatch metrics** for performance insights and alerting
- Configure **Auto-Tune** for provisioned domains to optimize performance automatically

---