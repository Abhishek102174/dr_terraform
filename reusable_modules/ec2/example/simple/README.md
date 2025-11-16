# EC2 Example with VPC and Security Group 

This example demonstrates provisioning of **EC2 instances** in **private subnets** using a custom VPC and security group. It uses the reusable EC2 module with features like EBS volumes, monitoring, alarms, and optional key pair generation.

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

- A VPC with public and private subnets across two availability zones.
- NAT Gateway for internet access from private subnets.
- Security group allowing HTTP, HTTPS, and SSH access.
- Two EC2 instances in private subnets.
- Optional EBS volume attached to each instance.
- CPU CloudWatch alarms and detailed monitoring.

---

## Resources Created

| Resource                      | Description                             |
|-------------------------------|-----------------------------------------|
| `aws_vpc`                     | VPC for networking                      |
| `aws_subnet`                  | Public and private subnets              |
| `aws_nat_gateway`             | NAT Gateway for private subnet access   |
| `aws_security_group`          | Allow SSH, HTTP access                  |
| `aws_instance`                | EC2 instances                           |
| `aws_cloudwatch_metric_alarm` | CPU alarms                              |
| `aws_key_pair` (optional)     | SSH key if generated                    |
| `aws_ebs_volume`              | Extra attached volume per instance      |

---

## Usage

```hcl
provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
  name    = "ec2-example-vpc"
  cidr    = "10.0.0.0/16"
  azs     = ["us-east-1a", "us-east-1b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_security_group" "web" {
  name        = "ec2-example-sg"
  vpc_id      = module.vpc.vpc_id
  description = "Allow HTTP/HTTPS and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2_cluster" {
  source              = "../../"
  region              = "us-east-1"
  instance_count      = 2
  ami_id              = "ami-0ec18f6103c5e0491"
  instance_type       = "t3.micro"
  name_prefix         = "app-server"
  create_key_pair     = true
  key_pair_name       = "example-keypair-${terraform.workspace}"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.web.id]

  root_volume_size    = 20
  root_volume_type    = "gp3"
  root_volume_encrypted = true
  delete_on_termination = true

  ebs_volumes = [{
    device_name = "/dev/sdf"
    size        = 10
    type        = "gp3"
    iops        = 3000
    throughput  = 125
    encrypted   = true
    kms_key_id  = null
  }]

  enable_monitoring = true
  enable_cpu_alarm  = true
  allocate_eips     = false

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "ec2-example"
  }
}
```

---

## Best Practices

- Use private subnets and NAT gateways to enhance security for internal services.
- Enable CloudWatch alarms to monitor instance health.
- Avoid assigning public IPs unless required.
- Use encrypted EBS volumes with KMS keys for security.
- Tag resources for better manageability and billing visibility.

---
