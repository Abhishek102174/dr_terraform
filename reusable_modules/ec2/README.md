# EC2 Instance Terraform Module

This Terraform module provisions one or more **Amazon EC2 instances** with optional features including: 

- Key pair generation or external key usage
- Encrypted EBS volumes
- Elastic IPs (EIPs)
- CloudWatch monitoring and alarms

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Usage](#usage)
- [Input Variables](#input-variables)
- [Resources Created](#resources-created)
- [Outputs](#outputs)
- [Best Practices](#best-practices)

---

## Overview

This module enables creation of EC2 instances with flexible configurations:

- Allows creation of one or more instances
- Generate a new key pair or use an existing one
- Root and additional EBS volume support
- Automatically assign EIPs per instance
- Configure CloudWatch CPU alarms
- Set custom tags and names

---

## Usage Example

```hcl
module "ec2" {
  source             = "git::https://github.com/Waters-EMU/it-web-terraform-modules.git//modules/ec2?ref=v2.0.0"
  # (Always verifiy the latest version by going to the "tags" tab, and use the latest tag)
  instance_count     = 2
  ami_id             = "ami-0123456789abcdef0"
  instance_type      = "t3.micro"
  name_prefix        = "webserver"
  key_name           = "existing-key"
  create_key_pair    = false
  public_key         = null
  subnet_ids         = ["subnet-123abc", "subnet-456def"]
  security_group_ids = ["sg-0123456789abcdef0"]
  associate_public_ip = true
  enable_monitoring  = true
  allocate_eips      = true
  region             = "us-east-1"

  root_volume_size   = 20
  root_volume_type   = "gp3"
  root_volume_iops   = 3000
  root_volume_throughput = 125
  root_volume_encrypted = true
  delete_on_termination  = true
  kms_key_arn        = "arn:aws:kms:us-east-1:123456789012:key/abc123"

  ebs_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 50
      type        = "gp3"
      iops        = 3000
      throughput  = 125
      encrypted   = true
    }
  ]

  enable_cpu_alarm = true
  tags = {
    Environment = "dev"
    Owner       = "team-infra"
  }
}
```

---

## Input Variables

| Name                    | Type    | Description                                                   | Required |
|-------------------------|---------|---------------------------------------------------------------|----------|
| `instance_count`        | number  | Number of EC2 instances to create                             | Yes      |
| `ami_id`                | string  | AMI ID for the EC2 instance                                   | Yes      |
| `instance_type`         | string  | Instance type (e.g., `t3.micro`)                              | Yes      |
| `key_name`              | string  | Existing key pair name (if `create_key_pair = false`)         | Yes      |
| `create_key_pair`       | bool    | Whether to generate a new key pair                            | Yes      |
| `public_key`            | string  | Public key content (used if not generating new key)           | No       |
| `subnet_ids`            | list    | List of subnet IDs to use                                     | Yes      |
| `security_group_ids`    | list    | List of security group IDs                                    | Yes      |
| `associate_public_ip`   | bool    | Whether to assign public IPs                                  | No       |
| `allocate_eips`         | bool    | Whether to allocate Elastic IPs                               | No       |
| `enable_monitoring`     | bool    | Enable detailed monitoring                                     | No       |
| `enable_cpu_alarm`      | bool    | Enable CPU CloudWatch alarms                                  | No       |
| `region`                | string  | AWS region                                                    | Yes      |
| `name_prefix`           | string  | Prefix for EC2 instance names                                 | Yes      |
| `root_volume_*`         | various | Root volume configuration options                             | Yes      |
| `ebs_volumes`           | list    | List of additional EBS volume maps                            | No       |
| `tags`                  | map     | Tags applied to all resources                                 | No       |

---

## Resources Created

| Resource                        | Description                                 |
|---------------------------------|---------------------------------------------|
| `aws_instance`                  | EC2 instance(s) that will be created        |
| `aws_key_pair`                  | (Optional) Key pair if generated            |
| `aws_eip`                       | (Optional) Elastic IP for each instance     |
| `aws_cloudwatch_metric_alarm`   | (Optional) CPU alarm per instance           |
| `tls_private_key`               | (Optional) TLS key if generating key pair   |

---

## Best Practices

- Set `delete_on_termination = false` for critical volume retention.
- Use KMS for encrypting volumes to enhance security.
- Enable EIPs if public access or static IP is needed.
- Avoid `force_destroy = true` in production.
- Enable alarms for auto-scaling or notification actions.

---
 