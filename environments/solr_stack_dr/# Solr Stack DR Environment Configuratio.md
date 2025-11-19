# Solr Stack DR Environment Configuration

This file documents the `dr.json` inputs used to parameterize the Solr DR stack. Values are read at root and passed to `module.solr_stack` and, indirectly, to shared networking.

## Overview

- Location: `environments/solr_stack_dr/dr.json`
- Loaded in root and merged into `local.env_solr` (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:20–33`)
- Consumed by `module.solr_stack` (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:115–161`)

## Fields

- `name_prefix`
  - Prefix for Solr resources (ALB, IAM role/instance profile, EFS, S3)
  - Used by `module.solr_stack` for naming (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:119`)

- `vpc_cidr_block`
  - Informational VPC CIDR reference for security rules; the actual VPC CIDR is taken from `module.vpc.cidr_block` (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:121`)

- `subnet_cidr_base`
  - Base CIDR to derive Solr subnets (3 private, 1 public)
  - Used by Solr subnets (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:122` and `modules/solr_stack_dr/main.tf:75–85`)

- `key_name`
  - Existing EC2 Key Pair name for SSH access to Solr nodes
  - Passed to autoscaling launch template via Solr module (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:125`, `modules/solr_stack_dr/main.tf:18–27`, `reusable_modules/autoscaling/main.tf:1–12`)

- `instance_type`
  - EC2 type for Solr nodes (CPU/memory sizing)
  - Used in launch template via autoscaling (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:137`, `reusable_modules/autoscaling/main.tf:1–6`)

- `cluster_size`
  - Number of Solr nodes in the Auto Scaling Group
  - Used for ASG desired capacity (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:138`, `reusable_modules/autoscaling/main.tf:29–46`)

- `data_volume_size`
  - EBS data volume size in GB for each Solr node
  - Used in autoscaling block device mappings (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:139`, `modules/solr_stack_dr/main.tf:470–479`)

- `data_volume_iops`
  - Provisioned IOPS for Solr data volume (performance tuning)
  - Used in Solr module for EBS configuration (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:140`)

- `health_check_grace_period`
  - ASG grace period (seconds) before health checks mark instances unhealthy
  - Used by autoscaling (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:143`, `reusable_modules/autoscaling/main.tf:29–46`)

- `enable_deletion_protection`
  - Enable ALB deletion protection to prevent accidental deletion
  - Used by ALB config (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:144`, `modules/solr_stack_dr/main.tf:329–336`)

- `solr_fallback_ami_id`
  - Fallback AMI ID for Solr instances if a specific AMI isn’t provided
  - Used to build launch template (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:129`, `modules/solr_stack_dr/main.tf:36–39`)

- `common_tags`
  - Standard tags applied to Solr resources for cost allocation, ownership, and environment tracking
  - Combined and applied across resources (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:155–160`)

## Networking Correlation

- Solr creates subnets and outputs:
  - `solr_public_subnet_ids`, `solr_private_subnet_ids` (`d:\dr_terraform\dr_terraform_org\dr_terraform\modules\solr_stack_dr\outputs.tf:6–14`)
- Networking uses Solr subnets to create IGW/NAT/TGW when enabled:
  - Root wiring uses Solr outputs for placement (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:80–89`)
- Solr route tables consume networking outputs:
  - IGW → public routes, NAT → private routes (`d:\dr_terraform\dr_terraform_org\dr_terraform\main.tf:133–135`, `modules/solr_stack_dr/main.tf:90–98`, `124–131`)
- To disable NAT/IGW creation, manage flags in `environments/network/dr.json` (`create_nat_gateways`, `nat_gateway_count`, `create_igw`).

## Key Management

- `key_name` must match an existing AWS EC2 key pair
- If you only have a private key:
  - Generate public key (Windows PowerShell):
    - `ssh-keygen -y -f "C:\Users\abhis\Downloads\solr-dr.pem" > "C:\Users\abhis\Downloads\solr-dr.pub"`
  - Use the public key content for key pair import if needed

## Tips

- Use valid AMI IDs for `solr_fallback_ami_id` in the target region (`us-east-1` by default)
- Keep multiline secrets (private keys) in CI as environment variables (`TF_VAR_*`) rather than inline CLI `-var` flags to avoid parsing issues