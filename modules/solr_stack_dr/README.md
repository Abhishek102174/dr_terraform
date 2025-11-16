# Solr Stack DR Module

This module creates a complete disaster recovery (DR) replica of the Solr stack infrastructure based on the production environment analysis.

## Architecture Overview

The module provisions:
- **VPC**: Isolated network environment with DNS support
- **Subnets**: 3 private subnets (Solr instances) + 3 public subnets (NAT gateways)
- **Auto Scaling Group**: 3-node Solr cluster across multiple AZs
- **Application Load Balancer**: Internal ALB for Solr admin interface
- **Security Groups**: Network access control for Solr services
- **IAM Roles**: Instance permissions for Solr operations
- **KMS Encryption**: EBS volume encryption
- **NAT Gateways**: Internet access for private instances

## Infrastructure Mapping

Based on production Solr stack analysis:

| Production Component | DR Module Component | Notes |
|---------------------|-------------------|-------|
| `tf-asg-20201116170819390400000002` | `solr_autoscaling` | 3-node ASG |
| `solr-launch-tmpl` | `aws_launch_template.solr_template` | Launch template |
| `searchadmin-ilb` | `solr_alb` | Internal ALB |
| `waters-key-solr` | `var.key_name` | SSH key pair |
| `solr_zk_profile` | `solr_iam_role` | IAM instance profile |
| 50GB io2 volumes | Data volume mapping | Persistent storage |

## Usage

```hcl
module "solr_dr_stack" {
  source = "./modules/solr_stack_dr"
  
  name_prefix = "solr-dr-west"
  vpc_cidr    = "10.201.0.0/20"
  key_name    = "solr-dr-key"
  
  # Instance configuration
  instance_type     = "m5.xlarge"
  cluster_size      = 3
  data_volume_size  = 50
  data_volume_iops  = 150
  
  # Operational settings
  health_check_grace_period = 1200
  enable_deletion_protection = true
  
  common_tags = {
    Environment = "dr"
    Region      = "us-west-2"
    Purpose     = "disaster-recovery"
  }
}
```

## Key Features

### High Availability
- **Multi-AZ Deployment**: Instances distributed across 3 availability zones
- **Auto Scaling**: Maintains exactly 3 instances for cluster consistency
- **Health Checks**: Extended grace period (1200s) for Solr startup

### Storage Architecture
- **Root Volume**: 100GB gp3 (OS and applications)
- **Data Volume**: 50GB io2 with 150 IOPS (Solr indexes)
- **Encryption**: All volumes encrypted with dedicated KMS key
- **Persistence**: Data volumes survive instance termination

### Network Security
- **Private Subnets**: Solr instances in private subnets only
- **Security Groups**: Restricted access (SSH, Solr:8983, Zookeeper:2181)
- **Internal ALB**: Admin interface accessible only within VPC
- **NAT Gateways**: Outbound internet access for updates

### Operational Features
- **Launch Template**: Versioned instance configuration
- **User Data**: Automated volume mounting and Solr startup
- **Target Group**: Health checks via `/solr/admin/ping`
- **IAM Integration**: Proper permissions for EC2 operations

## Disaster Recovery Considerations

### Data Replication
- Configure Solr index replication from primary region
- Implement snapshot-based backup strategy for EBS volumes
- Set up cross-region snapshot copying

### Failover Process
1. Update DNS records to point to DR region
2. Verify Solr cluster health and index consistency
3. Update application configurations for new endpoints
4. Monitor cluster performance and scaling

### Recovery Testing
- Regular DR drills to validate infrastructure
- Index consistency verification procedures
- Performance benchmarking against production

## Monitoring and Alerting

The module includes CloudWatch integration for:
- Auto Scaling Group metrics
- Load balancer health checks
- EBS volume performance
- Instance-level monitoring

## Cost Optimization

- **Instance Types**: Right-sized m5.xlarge instances
- **Storage**: io2 volumes for consistent performance
- **NAT Gateways**: One per AZ for high availability
- **Deletion Protection**: Prevents accidental resource deletion

## Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- Existing key pair for SSH access
- Solr AMI available in target region

## Outputs

The module provides comprehensive outputs for integration:
- VPC and subnet IDs
- Load balancer DNS name and ARN
- Auto Scaling Group details
- Security group IDs
- IAM role ARNs

## Version Compatibility

- Terraform: >= 1.0
- AWS Provider: >= 5.0
- Compatible with existing it-web-terraform-modules
