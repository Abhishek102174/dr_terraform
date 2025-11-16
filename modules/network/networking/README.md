# Networking Module

This module provides core networking infrastructure components that can be shared across multiple services in the DR environment.

## Components

- **Internet Gateway** - Provides internet connectivity for the VPC
- **NAT Gateways** - Enables outbound internet access for private subnets
- **Elastic IPs** - Static IP addresses for NAT gateways
- **Transit Gateway** - Cross-VPC and on-premises connectivity (optional)

## Usage

```hcl
module "networking" {
  source = "./modules/networking"
  
  name_prefix = "dr-west"
  vpc_id      = module.vpc.vpc_id
  
  # Internet Gateway
  create_igw = true
  
  # NAT Gateways
  create_nat_gateways = true
  nat_gateway_count   = 3
  public_subnet_ids   = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
  
  # Transit Gateway (optional)
  create_tgw = true
  tgw_subnet_ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
  
  common_tags = {
    Environment = "dr"
    Project     = "disaster-recovery"
  }
}
```

## Outputs

- `internet_gateway_id` - ID of the Internet Gateway
- `nat_gateway_ids` - List of NAT Gateway IDs
- `nat_gateway_public_ips` - List of NAT Gateway public IPs
- `transit_gateway_id` - ID of the Transit Gateway (if created)

## Benefits of Separation

1. **Reusability** - Can be used by multiple service modules (Solr, MongoDB, AEM, etc.)
2. **Maintainability** - Networking changes don't affect service-specific modules
3. **Cost Optimization** - Shared NAT gateways reduce costs
4. **Consistency** - Standardized networking across all services
5. **Modularity** - Clear separation of concerns
