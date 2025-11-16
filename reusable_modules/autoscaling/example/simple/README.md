# Auto Scaling Group - Simple Example

This example demonstrates how to use the **AutoScaling Terraform Module** with a complete infrastructure setup including VPC, load balancer, and all necessary supporting resources.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Usage](#usage)
- [What This Example Creates](#what-this-example-creates)
- [Input Variables](#input-variables)
- [Outputs](#outputs)
- [Testing](#testing)
- [Cleanup](#cleanup)
- [Customization](#customization)

---

## Overview

This example creates a complete, production-ready Auto Scaling setup with:
- **VPC with public and private subnets** across 2 Availability Zones
- **Application Load Balancer** for distributing traffic
- **NAT Gateways** for secure internet access from private instances
- **Auto Scaling Group** with web server instances
- **SNS notifications** for scaling events (optional)
- **Security groups** with appropriate ingress/egress rules

The Auto Scaling Group launches Amazon Linux 2 instances that automatically install and configure Apache HTTP server.

---

## Architecture

```
Internet Gateway
       |
   Public Subnets (2 AZs)
       |
Application Load Balancer
       |
   Private Subnets (2 AZs)
       |
Auto Scaling Group (1-5 instances)
       |
   NAT Gateways (2 AZs)
```

---

## Prerequisites

- Terraform CLI >= 1.12.2
- AWS CLI configured with appropriate permissions
- AWS credentials with permissions for:
  - EC2 (instances, security groups, launch templates)
  - VPC (subnets, route tables, internet/NAT gateways)
  - ELB (load balancers, target groups)
  - Auto Scaling (groups, policies)
  - SNS (topics, subscriptions) - if notifications enabled
  - IAM (for service roles if needed)

---

## Usage

### Basic Usage

```bash
# Clone the repository
git clone https://github.com/Waters-EMU/it-web-terraform-modules.git
cd it-web-terraform-modules/modules/AutoScaling/example/simple

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### With SNS Notifications

```bash
# Enable SNS notifications
terraform apply -var="enable_sns_notifications=true"
```

### Custom Configuration

```bash
# Use custom values
terraform apply \
  -var="enable_sns_notifications=true" \
  -var="instance_type=t3.small" \
  -var="min_size=2" \
  -var="max_size=10"
```

---

## What This Example Creates

### Networking Infrastructure
- **1 VPC** with DNS hostnames and support enabled
- **2 Public Subnets** (one per AZ) with auto-assign public IP
- **2 Private Subnets** (one per AZ) for Auto Scaling instances
- **1 Internet Gateway** for public internet access
- **2 NAT Gateways** with Elastic IPs for private subnet internet access
- **Route Tables** with appropriate routing for public and private subnets

### Security
- **Default Security Group** with outbound internet access
- **Web Security Group** allowing HTTP (80) and HTTPS (443) inbound traffic

### Load Balancing
- **Application Load Balancer** (internet-facing) in public subnets
- **Target Group** with health checks on port 80
- **Load Balancer Listener** forwarding HTTP traffic to target group

### Auto Scaling
- **Launch Template** with Amazon Linux 2 AMI and Apache installation
- **Auto Scaling Group** with 2 desired instances (1-5 range)
- **Scale Up/Down Policies** with 5-minute cooldowns
- **Instance Refresh** enabled for zero-downtime updates

### Notifications (Optional)
- **SNS Topic** for Auto Scaling notifications
- **Notification Configuration** for launch/terminate events

---

## Input Variables

| Name                        | Type | Default | Description                             |
|-----------------------------|------|---------|-----------------------------------------|
| `enable_sns_notifications`  | bool | `false` | Enable SNS notifications for ASG events |

---

## Outputs

| Name                     | Description                                    |
|--------------------------|------------------------------------------------|
| `vpc_id`                 | ID of the created VPC                          |
| `public_subnet_ids`      | IDs of the public subnets                      |
| `private_subnet_ids`     | IDs of the private subnets                     |
| `load_balancer_dns_name` | DNS name of the Application Load Balancer      |
| `load_balancer_zone_id`  | Zone ID of the Application Load Balancer       |
| `autoscaling_group_name` | Name of the Auto Scaling Group                 |
| `launch_template_id`     | ID of the Launch Template                      |
| `sns_topic_arn`          | ARN of SNS topic (if notifications enabled)    |

---

## Testing

### 1. Verify Load Balancer
After deployment, test the load balancer endpoint:

```bash
# Get the load balancer DNS name
terraform output load_balancer_dns_name

# Test the endpoint
curl http://$(terraform output -raw load_balancer_dns_name)
```

Expected response:
```html
<h1>Hello from AutoScaling Instance!</h1>
```

### 2. Check Auto Scaling Group
```bash
# List instances in the ASG
aws autoscaling describe-auto-scaling-groups \
  --auto-scaling-group-names $(terraform output -raw autoscaling_group_name) \
  --query 'AutoScalingGroups[0].Instances[*].[InstanceId,HealthStatus,LifecycleState]' \
  --output table
```

### 3. Test Scaling (Manual)
```bash
# Scale up to 3 instances
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $(terraform output -raw autoscaling_group_name) \
  --desired-capacity 3

# Scale back down to 2 instances
aws autoscaling set-desired-capacity \
  --auto-scaling-group-name $(terraform output -raw autoscaling_group_name) \
  --desired-capacity 2
```

---

## Cleanup

To destroy all created resources:

```bash
terraform destroy
```

**Note**: This will delete all resources including the VPC, load balancer, and any running instances.

---

## Customization

### Modify Instance Configuration

```hcl
# In main.tf, update the module call
module "autoscaling" {
  # ... existing configuration ...
  
  instance_type = "t3.medium"  # Change instance type
  min_size      = 2            # Increase minimum instances
  max_size      = 10           # Increase maximum instances
  
  # Custom user data
  user_data = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Custom Web Server - $(hostname)</h1>" > /var/www/html/index.html
  EOF
}
```

### Add HTTPS Support

```hcl
# Add HTTPS listener to load balancer
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.main.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "arn:aws:acm:region:account:certificate/certificate-id"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
```

### Enable Detailed Monitoring

```hcl
module "autoscaling" {
  # ... existing configuration ...
  
  # Add to launch template configuration
  monitoring_enabled = true
}
```

---

## Best Practices Demonstrated

- **Multi-AZ Deployment**: Instances distributed across multiple Availability Zones
- **Private Instances**: Web servers in private subnets with NAT Gateway internet access
- **Load Balancer Health Checks**: ELB health checks for accurate instance health detection
- **Rolling Updates**: Instance refresh enabled for zero-downtime deployments
- **Security Groups**: Principle of least privilege with specific port access
- **Resource Tagging**: Consistent tagging across all resources
- **Infrastructure as Code**: Complete infrastructure defined in Terraform

---
