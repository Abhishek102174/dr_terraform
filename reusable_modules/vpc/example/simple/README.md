# VPC Module - Comprehensive Example

This example demonstrates how to use the VPC module with **all available features** including Transit Gateway, DHCP options, and VPC endpoints.

## What This Example Creates

### Core Infrastructure
- **VPC** with CIDR block 10.0.0.0/16
- **2 Public Subnets** in different AZs (us-east-1a, us-east-1b)
- **2 Private Subnets** in different AZs (us-east-1a, us-east-1b)
- **Internet Gateway** for public subnet internet access
- **NAT Gateways** for private subnet outbound internet access
- **Route Tables** and associations

### Advanced Features
- **DHCP Options Set** with custom domain name configuration
- **Transit Gateway** with VPC attachment and custom route table
- **VPC Endpoints** for AWS services:
  - **Gateway Endpoints**: S3, DynamoDB (free)
  - **Interface Endpoints**: EC2, SSM, EC2Messages, KMS, CloudWatch Logs
- **Security Group** for VPC endpoints with custom rules

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    VPC (10.0.0.0/16)                       │
│                                                             │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │  Public Subnet  │              │  Public Subnet  │      │
│  │  10.0.1.0/24    │              │  10.0.2.0/24    │      │
│  │   (us-east-1a)  │              │   (us-east-1b)  │      │
│  │                 │              │                 │      │
│  │   NAT Gateway   │              │   NAT Gateway   │      │
│  └─────────────────┘              └─────────────────┘      │
│           │                                │               │
│  ┌─────────────────┐              ┌─────────────────┐      │
│  │ Private Subnet  │              │ Private Subnet  │      │
│  │  10.0.10.0/24   │              │  10.0.20.0/24   │      │
│  │   (us-east-1a)  │              │   (us-east-1b)  │      │
│  └─────────────────┘              └─────────────────┘      │
│                                                             │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              VPC Endpoints                          │   │
│  │  • S3 (Gateway)     • EC2 (Interface)             │   │
│  │  • DynamoDB (Gateway) • SSM (Interface)           │   │
│  │  • KMS (Interface)  • CloudWatch Logs (Interface) │   │
│  └─────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                    ┌─────────────────┐
                    │ Transit Gateway │
                    │  (Multi-VPC)    │
                    └─────────────────┘
```

## Usage

### Quick Start
```bash
# Clone and navigate to example
cd modules/vpc/example/simple

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply
```

### Customization Options

You can customize the deployment by modifying variables:

```bash
# Deploy with minimal features (cost-effective)
terraform apply -var="create_tgw=false" -var="enable_vpc_endpoints=false"

# Deploy without NAT Gateways (private subnets won't have internet)
terraform apply -var="create_nat_gateway=false"

# Use different region
terraform apply -var="region=us-west-2"
```

## Configuration Variables

| Variable | Description | Default | Cost Impact |
|----------|-------------|---------|-------------|
| `create_tgw` | Create Transit Gateway | `true` | 💰 Hourly charges |
| `create_nat_gateway` | Create NAT Gateways | `true` | 💰💰 Hourly + data charges |
| `enable_vpc_endpoints` | Create VPC Endpoints | `true` | 💰 Interface endpoints have hourly charges |
| `create_dhcp_options` | Create DHCP options | `true` | ✅ Free |

## Outputs

After successful deployment, you'll get comprehensive information:

### Core Infrastructure
- VPC ID, ARN, and CIDR block
- Public and private subnet details
- Internet Gateway and NAT Gateway IDs
- Route table IDs

### Advanced Features
- Transit Gateway ID, ARN, and attachment details
- DHCP options set ID
- VPC endpoint IDs (gateway and interface)
- VPC endpoints security group ID

### Summary Output
```hcl
vpc_summary = {
  vpc_id                    = "vpc-xxxxxxxxx"
  public_subnets_count      = 2
  private_subnets_count     = 2
  nat_gateways_count        = 2
  dhcp_options_enabled      = true
  transit_gateway_enabled   = true
  vpc_endpoints_enabled     = true
  gateway_endpoints_count   = 2
  interface_endpoints_count = 5
}
```

## Cost Considerations

### 💰 Billable Resources
- **NAT Gateways**: ~$45/month each + data processing fees
- **Transit Gateway**: ~$36/month + attachment fees
- **Interface VPC Endpoints**: ~$7.20/month each

### ✅ Free Resources
- VPC, Subnets, Route Tables, Internet Gateway
- Gateway VPC Endpoints (S3, DynamoDB)
- DHCP Options, Security Groups

### Cost Optimization Tips
```bash
# Minimal cost deployment
terraform apply \
  -var="create_nat_gateway=false" \
  -var="create_tgw=false" \
  -var="enable_vpc_endpoints=false"

# Keep only free gateway endpoints
terraform apply \
  -var="enable_vpc_endpoints=true" \
  # Modify main.tf to remove interface endpoints
```

## Security Features

### VPC Endpoints Security
- Dedicated security group for VPC endpoints
- Configurable ingress/egress rules
- Private DNS enabled for interface endpoints

### Network Isolation
- Private subnets isolated from direct internet access
- Transit Gateway for secure inter-VPC communication
- Custom DHCP options for DNS resolution

## Cleanup

```bash
# Destroy all resources
terraform destroy

# Confirm destruction
# Type 'yes' when prompted
```

## Troubleshooting

### Common Issues

1. **Availability Zone Errors**
   ```bash
   # Check available AZs in your region
   aws ec2 describe-availability-zones --region us-east-1
   ```

2. **VPC Endpoint Service Availability**
   ```bash
   # List available VPC endpoint services
   aws ec2 describe-vpc-endpoint-services --region us-east-1
   ```

3. **Transit Gateway Limits**
   - Default limit: 5 Transit Gateways per region
   - Request limit increase if needed

## Next Steps

After deploying this example:
1. **Test Connectivity**: Launch EC2 instances in private subnets
2. **Verify VPC Endpoints**: Test S3 access without internet routing
3. **Transit Gateway**: Connect additional VPCs
4. **Monitoring**: Set up VPC Flow Logs and CloudWatch monitoring

## Related Examples

- **Basic VPC**: Minimal VPC with just public/private subnets
- **Multi-AZ Database**: VPC with database subnets
- **Hub-and-Spoke**: Multiple VPCs connected via Transit Gateway