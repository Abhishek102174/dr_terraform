# Simple Solr Stack DR Example

This example demonstrates how to deploy the Solr Stack DR module with basic configuration.

## Quick Start

1. **Copy the example variables file:**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. **Edit terraform.tfvars with your values:**
   ```hcl
   aws_region  = "us-west-2"
   name_prefix = "solr-dr-west"
   key_name    = "your-key-pair-name"
   ```

3. **Initialize and deploy:**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## What Gets Created

- **VPC**: 10.201.0.0/20 CIDR block
- **Subnets**: 3 private + 3 public subnets across AZs
- **Auto Scaling Group**: 3 Solr instances (m5.xlarge)
- **Load Balancer**: Internal ALB for Solr admin
- **Security Groups**: Restricted network access
- **IAM Roles**: Instance permissions
- **KMS Key**: EBS encryption
- **NAT Gateways**: Internet access for private instances

## Accessing Solr

After deployment, access the Solr admin interface:
```
http://<load_balancer_dns_name>:8983/solr/
```

The DNS name is provided in the Terraform outputs.

## Customization

Modify variables in `terraform.tfvars`:

```hcl
# Scale cluster size
cluster_size = 5

# Change instance type
instance_type = "m5.2xlarge"

# Increase data volume
data_volume_size = 100
data_volume_iops = 300
```

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy
```

## Prerequisites

- AWS CLI configured
- EC2 Key Pair created in target region
- Appropriate IAM permissions
- Terraform >= 1.0 installed
