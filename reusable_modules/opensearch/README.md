# OpenSearch Terraform Module

This Terraform module provisions **Amazon OpenSearch Service** domains and **OpenSearch Serverless** collections with comprehensive enterprise features including advanced cluster configuration, security options, logging, monitoring, VPC endpoints, and SAML authentication.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [Module Structure](#module-structure)
- [Resources Created](#resources-created)
- [Variables](#variables)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module creates and configures both OpenSearch domains and serverless collections with the following enterprise features:

### **OpenSearch Serverless Collections**
- **🚀 Serverless collections** with automatic scaling and pay-per-use pricing
- **🔒 Security policies** for encryption, network access, and data access
- **🌐 VPC integration** with private endpoints
- **📊 CloudWatch logging** for audit and error logs
- **🔐 AWS-owned or customer-managed encryption**

### **OpenSearch Domains (Provisioned)**
- **🏗️ OpenSearch domain** with configurable cluster settings (data, master, warm, cold storage)
- **🔒 Advanced security** with fine-grained access control and SAML authentication
- **🌐 Network options** - VPC deployment with private endpoints
- **🔐 Encryption** at rest and in transit with KMS support
- **📊 Comprehensive logging** - Index, search, application, and audit logs
- **⚡ Auto-Tune** for automatic performance optimization
- **📦 Package associations** for custom analyzers and dictionaries
- **🏷️ Flexible tagging** strategy

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- **Existing VPC with subnets** (for VPC deployment)
- **Security groups** configured for HTTPS traffic (port 443)
- **KMS keys** for encryption (optional - provide externally)
- IAM permissions for OpenSearch service creation

---

## Usage

### OpenSearch Serverless Collection (Recommended for Variable Workloads)

```hcl
module "opensearch_serverless" {
  source = "./modules/opensearch"

  # Serverless deployment
  deployment_type = "serverless"
  domain_name     = "my-search-collection"
  collection_type = "SEARCH"
  description     = "Serverless search collection"
  
  # Security policies
  create_encryption_policy   = true
  use_aws_owned_key         = true  # Cost-effective encryption
  create_network_policy     = true
  allow_from_public         = false # VPC private access
  create_data_access_policy = true
  
  # VPC configuration
  vpc_enabled        = true
  create_vpc_endpoint = true
  vpc_id             = "vpc-12345678"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  # Data access principals
  data_access_principals = [
    "arn:aws:iam::123456789012:root",
    "arn:aws:iam::123456789012:role/MyApplicationRole"
  ]
  
  # Logging
  audit_logs_enabled         = true
  error_logs_enabled         = true
  create_log_resource_policy = true
  log_retention_days         = 30
  
  # Use AWS-owned keys (no additional cost)
  create_kms_key = false
  
  tags = {
    Environment = "production"
    Service     = "search"
    Type        = "serverless"
  }
}
```

### Basic OpenSearch Domain (Development)

```hcl
module "opensearch_basic" {
  source = "./modules/opensearch"

  # Provisioned deployment
  deployment_type = "provisioned"
  domain_name     = "my-search-domain"
  engine_version  = "OpenSearch_2.3"
  
  # Cluster Configuration
  instance_type  = "t3.small.search"
  instance_count = 1
  
  # Storage
  volume_type = "gp3"
  volume_size = 20
  
  # Network - VPC deployment recommended
  vpc_enabled        = true
  subnet_ids         = ["subnet-12345678"]
  security_group_ids = ["sg-12345678"]
  
  # Security
  encrypt_at_rest          = true
  node_to_node_encryption = true
  enforce_https           = true
  
  tags = {
    Environment = "dev"
    Service     = "search"
  }
}
```

### Production OpenSearch Domain (Multi-AZ with Advanced Features)

```hcl
module "opensearch_production" {
  source = "./modules/opensearch"

  deployment_type = "provisioned"
  domain_name     = "prod-search-domain"
  engine_version  = "OpenSearch_2.3"
  
  # Multi-AZ Cluster Configuration
  instance_type             = "m6g.large.search"
  instance_count            = 3
  dedicated_master_enabled  = true
  zone_awareness_enabled    = true
  availability_zone_count   = 3
  
  # Storage Configuration
  volume_type = "gp3"
  volume_size = 100
  throughput  = 250
  
  # Network Configuration
  vpc_enabled        = true
  subnet_ids         = ["subnet-12345678", "subnet-87654321", "subnet-13579246"]
  security_group_ids = ["sg-12345678"]
  
  # Security Configuration
  encrypt_at_rest                    = true
  node_to_node_encryption           = true
  enforce_https                      = true
  advanced_security_enabled          = true
  internal_user_database_enabled     = true
  master_user_name                   = "admin"
  master_user_password               = "MySecurePassword123!"
  
  # Comprehensive Logging
  index_slow_logs_enabled      = true
  search_slow_logs_enabled     = true
  es_application_logs_enabled  = true
  audit_logs_enabled          = true
  create_log_resource_policy  = true
  log_retention_days          = 30
  
  # Auto-Tune
  auto_tune_desired_state = "ENABLED"
  
  # Custom KMS key
  create_kms_key = true
  enable_kms_key_rotation = true
  
  tags = {
    Environment = "production"
    Service     = "search"
    Backup      = "required"
  }
}
```

---

## Module Structure

```
modules/opensearch/
├── main.tf          # OpenSearch domain/collection and related resources
├── variables.tf     # Input variables (60+ variables)
├── outputs.tf       # Output values (comprehensive outputs)
├── versions.tf      # Provider requirements
├── README.md        # This documentation
└── example/         # Usage examples
    └── simple/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        ├── provider.tf
        ├── versions.tf
        └── README.md
```

---

## Resources Created

### Serverless Resources
| Resource                                    | Description                                    |
|---------------------------------------------|------------------------------------------------|
| `aws_opensearchserverless_collection`       | OpenSearch Serverless collection              |
| `aws_opensearchserverless_security_policy`  | Encryption, network, and data access policies |
| `aws_opensearchserverless_vpc_endpoint`     | VPC endpoint for private access                |

### Provisioned Resources
| Resource                                    | Description                                    |
|---------------------------------------------|------------------------------------------------|
| `aws_opensearch_domain`                     | Main OpenSearch domain                         |
| `aws_iam_service_linked_role`               | Service-linked role for OpenSearch            |
| `aws_opensearch_domain_policy`              | Separate domain access policy                  |
| `aws_opensearch_vpc_endpoint`               | VPC endpoint for private access                |
| `aws_opensearch_package_association`        | Custom package associations                    |
| `aws_opensearch_domain_saml_options`        | SAML authentication configuration              |

### Common Resources
| Resource                                    | Description                                    |
|---------------------------------------------|------------------------------------------------|
| `aws_cloudwatch_log_group`                 | CloudWatch log groups for logs                |
| `aws_cloudwatch_log_resource_policy`        | CloudWatch log resource policy                |
| `aws_kms_key`                              | Custom KMS key for encryption                 |
| `aws_kms_alias`                            | KMS key alias                                 |

---

## Variables

### Required Variables
- `deployment_type` - Choose "serverless" or "provisioned"
- `domain_name` - Name of the OpenSearch domain/collection

### Key Optional Variables
- `collection_type` - Collection type for serverless: "SEARCH", "TIMESERIES", "VECTORSEARCH"
- `use_aws_owned_key` - Use AWS-owned encryption keys (default: true)
- `vpc_enabled` - Enable VPC deployment (default: true)
- `create_kms_key` - Create custom KMS key (default: false)
- `advanced_security_enabled` - Enable fine-grained access control (default: false)
- `audit_logs_enabled` - Enable audit logging (default: false)

For complete variable list, see [variables.tf](./variables.tf)

---

## Outputs

### Serverless Collection Outputs
- `serverless_collection_arn` - ARN of the serverless collection
- `serverless_collection_endpoint` - Collection endpoint for API requests
- `serverless_dashboard_endpoint` - OpenSearch Dashboards endpoint

### Domain Outputs
- `domain_arn` - ARN of the OpenSearch domain
- `domain_endpoint` - Domain endpoint for API requests
- `dashboard_endpoint` - OpenSearch Dashboards endpoint

### Common Outputs
- `vpc_endpoint_id` - VPC endpoint ID (if created)
- `kms_key_id` - KMS key ID (if created)
- `log_group_names` - CloudWatch log group names

For complete output list, see [outputs.tf](./outputs.tf)

---

## Best Practices

### Security
- ✅ **Use VPC deployment** for network isolation
- ✅ **Enable encryption** at rest and in transit
- ✅ **Use specific IAM principals** instead of wildcards
- ✅ **Enable audit logging** for compliance
- ✅ **Use AWS-owned keys** for cost-effective encryption
- ✅ **Configure proper security groups** for HTTPS only (port 443)

### Performance (Provisioned)
- ✅ **Choose appropriate instance types** based on workload
- ✅ **Enable dedicated master nodes** for production (3+ nodes)
- ✅ **Use zone awareness** for high availability
- ✅ **Configure Auto-Tune** for optimization
- ✅ **Monitor CloudWatch metrics** for performance insights

### Cost Optimization
- ✅ **Use serverless** for variable workloads
- ✅ **Use provisioned** for predictable workloads
- ✅ **Use AWS-owned keys** to avoid KMS charges
- ✅ **Set appropriate log retention** periods
- ✅ **Use warm/cold storage** for older data (provisioned)

### Networking
- ✅ **Use private subnets** for VPC deployment
- ✅ **Configure security groups** for HTTPS only
- ✅ **Consider VPC endpoints** for private API access
- ✅ **Plan subnet placement** across multiple AZs

### Operations
- ✅ **Enable comprehensive logging** for troubleshooting
- ✅ **Use consistent tagging** for resource management
- ✅ **Plan maintenance windows** for Auto-Tune operations
- ✅ **Use external KMS keys** for production encryption

---