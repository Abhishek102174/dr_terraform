# EFS Terraform Module

This module provisions **Amazon Elastic File System (EFS)** with comprehensive configuration options including mount targets, access points, encryption, backup policies, and replication.

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

This module supports:
- EFS file system creation with flexible configuration
- **Mount targets across multiple subnets**
- **Access points with POSIX user and root directory configuration**
- **Server-side encryption with KMS**
- **Automatic backup policies**
- **Cross-region replication**
- **Lifecycle policies for cost optimization**
- **File system policies for access control**
- Comprehensive tagging

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS Provider >= 5.40.0
- AWS CLI configured with proper permissions
- IAM permissions for EFS, KMS, EC2 (for mount targets)

---

## Usage Example

```hcl
module "efs_file_system" {
  source = "git::https://github.com/Waters-EMU/it-web-terraform-modules//modules/efs?ref=main"

  name               = "my-efs-system"
  performance_mode   = "generalPurpose"
  throughput_mode    = "bursting"
  encrypted          = true
  create_kms_key     = true
  
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  # Access points for different applications
  access_points = {
    app1 = {
      posix_user = {
        gid = 1001
        uid = 1001
      }
      root_directory = {
        path = "/app1"
        creation_info = {
          owner_gid   = 1001
          owner_uid   = 1001
          permissions = "755"
        }
      }
    }
    app2 = {
      posix_user = {
        gid = 1002
        uid = 1002
      }
      root_directory = {
        path = "/app2"
        creation_info = {
          owner_gid   = 1002
          owner_uid   = 1002
          permissions = "755"
        }
      }
    }
  }
  
  # Lifecycle policy for cost optimization
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  # Enable backup
  enable_backup_policy = true
  
  # Optional: Cross-region replication
  replication_configuration = {
    destination_region = "us-west-2"
  }
  
  tags = {
    Environment = "production"
    Team        = "platform"
  }
}
```

## Module Structure

```
modules/
└── efs/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── README.md
    └── example/
        └── simple/
            ├── main.tf
            ├── variables.tf
            ├── outputs.tf
            ├── provider.tf
            ├── versions.tf
            └── README.md
```

---

## Resources Used

| Resource                           | Purpose                                    |
|------------------------------------|--------------------------------------------| 
| `aws_efs_file_system`             | Creates EFS file system                    |
| `aws_efs_mount_target`            | Creates mount targets in subnets           |
| `aws_efs_access_point`            | Creates access points for applications     |
| `aws_efs_file_system_policy`      | Configures file system access policies    |
| `aws_efs_backup_policy`           | Enables automatic backups                  |
| `aws_efs_replication_configuration` | Sets up cross-region replication         |
| `aws_kms_key`                     | Creates KMS key for encryption             |
| `aws_kms_alias`                   | Creates KMS key alias                      |

---

## Input Variables

| Name                              | Type   | Description                                    | Required |
|-----------------------------------|--------|------------------------------------------------|----------|
| `name`                           | string | Name of the EFS file system                    | Yes      |
| `creation_token`                 | string | Unique creation token for the file system      | No       |
| `performance_mode`               | string | Performance mode (generalPurpose or maxIO)     | No       |
| `throughput_mode`                | string | Throughput mode (bursting or provisioned)      | No       |
| `provisioned_throughput_in_mibps` | number | Provisioned throughput in MiB/s               | No       |
| `encrypted`                      | bool   | Enable encryption at rest                       | No       |
| `kms_key_id`                     | string | ARN of existing KMS key for encryption          | No       |
| `create_kms_key`                 | bool   | Create a new KMS key for encryption             | No       |
| `subnet_ids`                     | list   | List of subnet IDs for mount targets           | No       |
| `security_group_ids`             | list   | List of security group IDs for mount targets   | No       |
| `access_points`                  | map    | Map of access points configuration              | No       |
| `lifecycle_policy`               | object | Lifecycle policy for cost optimization          | No       |
| `enable_backup_policy`           | bool   | Enable automatic backups                        | No       |
| `file_system_policy`             | string | File system policy JSON                         | No       |
| `replication_configuration`      | object | Cross-region replication configuration          | No       |
| `tags`                           | map    | Tags to apply to resources                      | No       |

---

## Outputs

| Name                          | Description                           |
|-------------------------------|---------------------------------------|
| `file_system_id`             | ID of the EFS file system            |
| `file_system_arn`            | ARN of the EFS file system           |
| `file_system_dns_name`       | DNS name of the EFS file system      |
| `mount_target_ids`           | Map of mount target IDs               |
| `mount_target_dns_names`     | Map of mount target DNS names         |
| `access_point_ids`           | Map of access point IDs               |
| `access_point_arns`          | Map of access point ARNs              |
| `kms_key_id`                 | ID of the KMS key used for encryption |
| `kms_key_arn`                | ARN of the KMS key used for encryption |
| `replication_configuration_id` | ID of the replication configuration  |

---

## Best Practices

- Use **generalPurpose** performance mode for most workloads
- Enable **encryption at rest** for sensitive data
- Use **access points** to control application access
- Configure **lifecycle policies** to reduce storage costs
- Enable **automatic backups** for production file systems
- Use **security groups** to control network access
- Implement **cross-region replication** for disaster recovery
- Use **provisioned throughput** only when consistent high performance is needed
- **Tag resources** for cost tracking and management
- Place mount targets in **multiple Availability Zones** for high availability

---