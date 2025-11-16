# ECS Module - Simple Example

This example demonstrates how to use the ECS Terraform module to create different types of ECS services including Fargate web applications, EC2 daemon services, and microservices with monitoring.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [What This Example Creates](#what-this-example-creates)
- [Variables](#variables)
- [Outputs](#outputs)
- [Customization](#customization)
- [Clean Up](#clean-up)
- [Troubleshooting](#troubleshooting)

---

## Overview

This example creates a complete ECS environment with:
- **VPC Infrastructure**: Complete networking setup with public/private subnets
- **Simple Fargate Web App**: Basic nginx service in private subnets
- **EC2 Daemon Service**: Monitoring agent running on EC2 instances
- **Custom Microservice**: HTTP server with health checks and autoscaling
- **Monitoring**: SNS topic for CloudWatch alarm notifications

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                        VPC (10.0.0.0/16)                   │
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │  Public Subnet  │              │  Public Subnet  │       │
│  │   10.0.1.0/24   │              │   10.0.2.0/24   │       │
│  │       AZ-a      │              │       AZ-b      │       │
│  └─────────────────┘              └─────────────────┘       │
│           │                                │                │
│           │                                │                │
│  ┌─────────────────┐              ┌─────────────────┐       │
│  │ Private Subnet  │              │ Private Subnet  │       │
│  │  10.0.10.0/24   │              │  10.0.11.0/24   │       │
│  │   [ECS Tasks]   │              │   [ECS Tasks]   │       │
│  └─────────────────┘              └─────────────────┘       │
└─────────────────────────────────────────────────────────────┘

ECS Services Created:
┌──────────────────────┐ ┌──────────────────────┐ ┌──────────────────────┐
│   simple-web-app     │ │   monitoring-daemon  │ │  custom-microservice │
│    (Fargate)         │ │        (EC2)         │ │      (Fargate)       │
│   nginx:latest       │ │  cloudwatch-agent    │ │    httpd:latest      │
│   Desired: 1         │ │     DAEMON           │ │    Desired: 2        │
└──────────────────────┘ └──────────────────────┘ └──────────────────────┘
```

---

## Prerequisites

- **Terraform**: >= 1.12.2
- **AWS CLI**: Configured with appropriate permissions
- **AWS Provider**: >= 5.40.0
- **IAM Permissions**: ECS, VPC, CloudWatch, SNS, IAM
- **Email Access**: For receiving SNS notifications

---

## Usage

### Step 1: Clone and Navigate

```bash
git clone https://github.com/Waters-EMU/it-web-terraform-modules.git
cd it-web-terraform-modules/modules/ECS/example/simple
```

### Step 2: Configure Variables

Create a `terraform.tfvars` file:

```hcl
region = "us-west-2"
notification_email = "your-email@company.com"
```

### Step 3: Initialize and Plan

```bash
terraform init
```

```bash
terraform plan
```

### Step 4: Apply Configuration

```bash
terraform apply
```

### Step 5: Confirm SNS Subscription

Check your email and confirm the SNS subscription to receive CloudWatch alarm notifications.

---

## What This Example Creates

### Networking Infrastructure

| Resource         | Purpose                               | Configuration                            |
|------------------|---------------------------------------|------------------------------------------|
| VPC              | Isolated network environment          | CIDR: 10.0.0.0/16                        |
| Public Subnets   | Internet-facing resources             | 10.0.1.0/24, 10.0.2.0/24                 |
| Private Subnets  | ECS tasks and internal resources      | 10.0.10.0/24, 10.0.11.0/24               |
| Internet Gateway | Internet access for public subnets    | Attached to VPC                          |
| NAT Gateway      | Outbound internet for private subnets | In public subnet                         |
| Route Tables     | Traffic routing                       | Public and private configurations        |

### Security Groups

| Security Group   | Purpose           | Rules                               |
|----------------  |-------------------|-------------------------------------|
| `ecs-fargate-sg` | Fargate tasks     | Inbound: 80, 8080; Outbound: All    |
| `ecs-ec2-sg`     | EC2 ECS instances | Inbound: 32768-65535; Outbound: All |

### ECS Services

#### 1. Simple Web Application (Fargate)
- **Name**: `simple-web-app`
- **Image**: `nginx:latest`
- **Resources**: 256 CPU, 512 MB memory
- **Network**: Private subnets, no public IP
- **Features**: CloudWatch logging enabled

#### 2. Monitoring Daemon (EC2)
- **Name**: `monitoring-daemon`
- **Image**: `amazon/cloudwatch-agent:latest`
- **Resources**: 128 CPU, 256 MB memory
- **Strategy**: DAEMON (one per EC2 instance)
- **Features**: Health checks enabled

#### 3. Custom Microservice (Fargate)
- **Name**: `custom-microservice`
- **Image**: `httpd:latest`
- **Resources**: 256 CPU, 512 MB memory
- **Replicas**: 2 tasks
- **Features**: Autoscaling, health checks, SNS alerts

### Monitoring and Alerting

| Component       | Purpose            | Configuration     |
|-----------------|--------------------|-------------------|
| SNS Topic       | Alert notifications| Email subscription|
| CloudWatch Logs | Container logging  | 7-day retention   |
| Health Checks   | Service monitoring | HTTP-based checks |

---

## Variables

| Variable             | Type   | Default               | Description                        |
|----------------------|--------|-----------------------|------------------------------------|
| `region`             | string | `"us-east-1"`         | AWS region for deployment          |
| `notification_email` | string | `"admin@example.com"` | Email for CloudWatch notifications |

---

## Outputs

After successful deployment, you'll see outputs including:

- **VPC ID**: The created VPC identifier
- **Subnet IDs**: Public and private subnet identifiers
- **ECS Cluster ARNs**: ARNs of created ECS clusters
- **Service Names**: Names of created ECS services
- **SNS Topic ARN**: ARN of the notification topic

---

## Customization

### Adding More Services

To add additional ECS services, append to the example:

```hcl
module "additional_service" {
  source = "../../"
  
  name        = "my-custom-service"
  region      = var.region
  launch_type = "FARGATE"
  
  # ... other configuration
}
```

### Modifying Resource Allocation

Adjust CPU and memory based on your needs:

```hcl
# In the module block
fargate_cpu    = "512"    # Increase CPU
fargate_memory = "1024"   # Increase memory
```

### Enabling Auto Scaling

Add auto-scaling configuration to services:

```hcl
# In the module block
enable_autoscaling = true
autoscaling_config = {
  min_capacity = 1
  max_capacity = 10
  target_value = 70
}
```

### Custom Container Images

Replace default images with your own:

```hcl
container_definitions = jsonencode([{
  name  = "my-app"
  image = "your-registry.com/my-app:v1.0.0"
  # ... rest of configuration
}])
```

---

## Clean Up

To destroy all resources created by this example:

```bash
terraform destroy
```

**Warning**: This will delete all resources including the VPC, subnets, ECS services, and data. Make sure you have backups if needed.

---

## Troubleshooting

### Common Issues

#### 1. Email Confirmation Required

**Issue**: Not receiving CloudWatch alerts
**Solution**: Check your email for SNS subscription confirmation and click the confirmation link

#### 2. Tasks Not Starting

**Issue**: ECS tasks fail to start or immediately stop
**Solutions**:
- Check CloudWatch logs: `/ecs/simple-web-app`
- Verify security group allows required ports
- Ensure subnets have available IP addresses

#### 3. Internet Connectivity Issues

**Issue**: Tasks can't pull images or access external services
**Solutions**:
- Verify NAT Gateway is created and routes are configured
- Check that private subnets route to NAT Gateway
- Ensure security groups allow outbound traffic

#### 4. Resource Limits

**Issue**: Services can't scale or tasks are pending
**Solutions**:
- Check AWS service limits for ECS
- Verify subnet capacity and available ENIs
- Review CPU/memory allocation vs. available resources

### Debugging Commands

```bash
# Check ECS service status
aws ecs describe-services --cluster simple-web-app-cluster --services simple-web-app-service
```

```bash
# View recent tasks
aws ecs list-tasks --cluster simple-web-app-cluster --service-name simple-web-app-service
```

```bash
# Check CloudWatch logs
aws logs get-log-events --log-group-name "/ecs/simple-web-app" --log-stream-name "$(aws logs describe-log-streams --log-group-name '/ecs/simple-web-app' --order-by LastEventTime --descending --limit 1 --query 'logStreams[0].logStreamName' --output text)"
```

```bash
# Verify VPC resources
aws ec2 describe-vpcs --filters "Name=tag:Name,Values=test-vpc"
```

---

## Cost Estimation

This example creates resources that will incur costs:

### Estimated Monthly Costs (us-east-1)

| Resource                         | Quantity       | Estimated Cost |
|----------------------------------|----------------|----------------|
| NAT Gateway                      | 1              | ~$45/month     |
| Fargate Tasks (256 CPU, 512 MB)  | 3 tasks        | ~$15-30/month  |
| CloudWatch Logs                  | Standard usage | ~$5-10/month   |
| EIP for NAT                      | 1              | ~$3.60/month   |

**Total Estimated**: ~$70-90/month

### Cost Optimization Tips

- Use smaller CPU/memory allocations for development
- Schedule non-critical services to run only during business hours
- Implement auto-scaling to scale down during low usage
- Consider using EC2 Spot instances for fault-tolerant workloads

---

## Next Steps

After running this example:

1. **Explore the Services**: Access the ECS console to see running tasks
2. **Monitor Performance**: Check CloudWatch dashboards and metrics
3. **Customize Configuration**: Modify the example for your specific needs
4. **Add Load Balancer**: Integrate with ALB for production traffic distribution
5. **Implement CI/CD**: Set up deployment pipelines for your applications
6. **Security Hardening**: Review and enhance security groups and IAM policies

---

## Support

For questions or issues with this example:

- Review the [main module documentation](../../README.md)
- Check AWS ECS documentation
- Open an issue in the repository
- Contact your platform team

---
