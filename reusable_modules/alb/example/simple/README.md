# ALB Module Simple Example

This example demonstrates how to use the ALB Terraform module to create both an Application Load Balancer (ALB) and a Network Load Balancer (NLB) with complete VPC infrastructure.

---

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [What This Example Creates](#what-this-example-creates)
- [Usage](#usage)
- [Architecture](#architecture)
- [Resources Created](#resources-created)
- [Outputs](#outputs)
- [Clean Up](#clean-up)

---

## Overview

This example creates:
- Complete VPC infrastructure with public and private subnets
- Internet Gateway and routing configuration
- Public Application Load Balancer with security group rules
- Private Network Load Balancer with Elastic IP addresses
- Demonstrates both internet-facing and internal load balancer configurations

---

## Prerequisites

- Terraform CLI >= 1.12.0
- AWS Provider >= 5.40.0
- AWS CLI configured with appropriate permissions
- AWS account with sufficient IAM permissions for VPC, EC2, and Load Balancer services

---

## What This Example Creates

### Infrastructure Components
- **VPC**: 10.0.0.0/16 CIDR with DNS resolution enabled
- **Internet Gateway**: For public internet access
- **Public Subnets**: 2 subnets (10.0.1.0/24, 10.0.2.0/24) across different AZs
- **Private Subnets**: 2 subnets (10.0.10.0/24, 10.0.11.0/24) across different AZs
- **Elastic IPs**: 2 EIPs for the Network Load Balancer
- **Route Tables**: Public routing with internet gateway access

### Load Balancers
- **Public ALB**: Internet-facing Application Load Balancer with HTTP/HTTPS security rules
- **Private NLB**: Internal Network Load Balancer with dedicated Elastic IPs

---

## Usage

### Deploy the Example

1. **Clone the repository and navigate to the example directory:**
   ```bash
   cd modules/ALB/example/simple
   ```

2. **Initialize Terraform:**
   ```bash
   terraform init
   ```

3. **Review the planned changes:**
   ```bash
   terraform plan
   ```

4. **Apply the configuration:**
   ```bash
   terraform apply
   ```

5. **Confirm the deployment:**
   ```
   Enter a value: yes
   ```
   

### Customize the Region

You can specify a different AWS region by setting the `region` variable:

```bash
terraform apply -var="region=us-west-2"
```

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                       │
│                                                                 │
│  ┌─────────────────┐                    ┌─────────────────┐    │
│  │   Public-1      │                    │   Public-2      │    │
│  │  10.0.1.0/24    │                    │  10.0.2.0/24    │    │
│  │      AZ-a       │                    │      AZ-b       │    │
│  └─────────────────┘                    └─────────────────┘    │
│           │                                       │             │
│           └───────────────┐       ┌───────────────┘             │
│                           │       │                             │
│                    ┌─────────────────┐                          │
│                    │  Public ALB     │                          │
│                    │ (Internet-facing)│                          │
│                    └─────────────────┘                          │
│                                                                 │
│  ┌─────────────────┐                    ┌─────────────────┐    │
│  │   Private-1     │                    │   Private-2     │    │
│  │  10.0.10.0/24   │                    │  10.0.11.0/24   │    │
│  │      AZ-a       │                    │      AZ-b       │    │
│  └─────────────────┘                    └─────────────────┘    │
│           │                                       │             │
│           └───────────────┐       ┌───────────────┘             │
│                           │       │                             │
│                    ┌─────────────────┐                          │
│                    │  Private NLB    │                          │
│                    │   (Internal)    │                          │
│                    └─────────────────┘                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Resources Created

| Resource Type                    | Count | Purpose                                  |
|----------------------------------|-------|------------------------------------------|
| `aws_vpc`                        | 1     | Main VPC for all resources               |
| `aws_internet_gateway`           | 1     | Internet access for public subnets       |
| `aws_subnet` (public)            | 2     | Public subnets across 2 AZs              |
| `aws_subnet` (private)           | 2     | Private subnets across 2 AZs             |
| `aws_route_table`                | 1     | Routing table for public subnets         |
| `aws_route_table_association`    | 2     | Associates public subnets to route table |
| `aws_eip`                        | 2     | Elastic IPs for NLB                      |
| ALB Module (public)              | 1     | Public Application Load Balancer         |
| ALB Module (private NLB)         | 1     | Private Network Load Balancer            |

---

## Outputs

This example provides the following outputs:

### VPC Information
- `vpc_id`: ID of the created VPC
- `public_subnet_ids`: List of public subnet IDs
- `private_subnet_ids`: List of private subnet IDs

### Public ALB Outputs
- `public_alb_arn`: ARN of the public Application Load Balancer
- `public_alb_dns_name`: DNS name for the public ALB
- `public_alb_zone_id`: Hosted zone ID for the public ALB
- `public_alb_security_group_id`: Security group ID for the public ALB

### Private NLB Outputs
- `private_nlb_arn`: ARN of the private Network Load Balancer  
- `private_nlb_dns_name`: DNS name for the private NLB
- `private_nlb_zone_id`: Hosted zone ID for the private NLB

### Example Output Usage
```bash
# Get the ALB DNS name
terraform output public_alb_dns_name

# Get all outputs in JSON format
terraform output -json
```

---

## Clean Up

To destroy all resources created by this example:

```bash
terraform destroy
```

**Warning**: This will permanently delete all resources. Make sure you want to proceed before confirming.

---

## Module Configuration Details

### Public ALB Configuration
- **Type**: Application Load Balancer
- **Scheme**: Internet-facing
- **Security**: HTTP (80) and HTTPS (443) access from anywhere
- **Subnets**: Deployed across public subnets
- **Deletion Protection**: Disabled (for testing purposes)

### Private NLB Configuration  
- **Type**: Network Load Balancer
- **Scheme**: Internal
- **IPs**: Uses dedicated Elastic IP addresses
- **Subnets**: Deployed across private subnets
- **Deletion Protection**: Disabled (for testing purposes)

### Important Notes
- Deletion protection is disabled in this example for easy cleanup
- In production, enable deletion protection to prevent accidental deletion
- The example uses sandbox tags - modify for your environment
- Security group rules allow broad access - tighten for production use

---
