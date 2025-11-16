# EFS Example

This example demonstrates provisioning of **Amazon Elastic File System (EFS)** using the reusable EFS module with common configuration options.

---

## Table of Contents

- [Overview](#overview)
- [Resources Created](#resources-created)
- [Features](#features)
- [Usage](#usage)
- [Best Practices](#best-practices)

---

## Overview

This configuration sets up:

- An **EFS file system** with multiple access points
- Mount targets across multiple subnets
- KMS encryption with customer-managed key
- Automatic backup policy
- Access points with POSIX user configuration
- Lifecycle policy for cost optimization

---

## Resources Created

| Resource                      | Description                             |
|-------------------------------|-----------------------------------------|
| `aws_efs_file_system`         | EFS file system                         |
| `aws_efs_mount_target`        | Mount targets in subnets                |
| `aws_efs_access_point`        | Access points for applications          |
| `aws_efs_backup_policy`       | Automatic backup policy                 |
| `aws_kms_key`                 | KMS key for encryption                  |
| `aws_kms_alias`               | KMS key alias                           |

---

## Features

- **Performance Mode**: General Purpose
- **Throughput Mode**: Bursting
- **Encryption**: Enabled with customer-managed KMS key
- **Access Points**: Multiple (webapp, shared)
- **Lifecycle Policy**: Transition to IA after 30 days
- **Backup**: Enabled

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "efs" {
  source = "../../"

  name             = "it-web-dev-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  create_kms_key   = true
  
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  security_group_ids = ["sg-12345678"]
  
  access_points = {
    webapp = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/webapp"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
    shared = {
      root_directory = {
        path = "/shared"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }
  
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  enable_backup_policy = true
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "it-web-dev-efs"
  }
}
```

### Deployment Steps

1. **Update Variables**: Modify `variables.tf` with your actual subnet IDs and security group IDs
2. **Initialize Terraform**: `terraform init`
3. **Plan Deployment**: `terraform plan`
4. **Apply Configuration**: `terraform apply`

### Mount Commands

After deployment, use these commands to mount the EFS file systems:

```bash
# Standard mount
sudo mount -t efs fs-xxxxxxxxx:/ /mnt/efs

# TLS encrypted mount
sudo mount -t efs -o tls fs-xxxxxxxxx:/ /mnt/efs

# Access point mounts
sudo mount -t efs -o tls,accesspoint=fsap-webapp fs-xxxxxxxxx:/ /mnt/efs-webapp
sudo mount -t efs -o tls,accesspoint=fsap-shared fs-xxxxxxxxx:/ /mnt/efs-shared
```

---

## Best Practices

- Use **generalPurpose** performance mode for most workloads
- Enable **TLS encryption** in transit for security
- Use **access points** to isolate application data
- Configure **lifecycle policies** to reduce storage costs
- Enable **automatic backups** for production file systems
- Use **provisioned throughput** only when consistent high performance is needed
- Implement **cross-region replication** for disaster recovery
- **Tag resources** for cost tracking and management
- Place mount targets in **multiple Availability Zones** for high availability
- Use **security groups** to control network access to EFS

---