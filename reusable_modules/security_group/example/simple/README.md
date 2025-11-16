# Security Group Module - Simple Example

This example demonstrates how to use the Security Group module to create security groups for web servers and databases.

## Usage

1. Set your VPC ID:
```bash
export TF_VAR_vpc_id="vpc-xxxxxxxxx"
```

2. Initialize and apply:
```bash
terraform init
terraform plan
terraform apply
```

## What this example creates

- **Web Server Security Group**: Allows HTTP (80), HTTPS (443) from anywhere, and SSH (22) from private networks
- **Database Security Group**: Allows MySQL (3306) and PostgreSQL (5432) access only from the web server security group

## Clean up

```bash
terraform destroy
```