# DR Terraform - Request Flow Documentation

## Overview
This document explains the complete data flow, module dependencies, and execution sequence of the DR Terraform infrastructure deployment. The architecture follows a multi-environment pattern using JSON-based configuration and reusable modules.

## Architecture Diagram
```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DR TERRAFORM ROOT                                 │
│                              main.tf                                        │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│                      ENVIRONMENT CONFIGURATION                              │
│                     /environments/*.json                                    │
│                   (dr.json, stage.json, prod.json)                         │
└─────────────────────────────────────────────────────────────────────────────┘
                                    │
                    ┌───────────────┼───────────────┐
                    ▼               ▼               ▼
            ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
            │ VPC MODULE  │ │SOLR STACK   │ │ NETWORKING  │
            │             │ │   MODULE    │ │   MODULE    │
            │ (First)     │ │ (Second)    │ │  (Third)    │
            └─────────────┘ └─────────────┘ └─────────────┘
                    │               │               │
                    └───────────────┼───────────────┘
                                    ▼
            ┌─────────────────────────────────────────────────────┐
            │              REUSABLE MODULES                       │
            │     /it-web-terraform-modules/modules/              │
            │  (vpc, security_group, alb, IAM, S3, autoscaling)  │
            └─────────────────────────────────────────────────────┘
```

## File and Folder Structure

### Root Directory Structure
```
/mnt/c/dr_terraform/
├── main.tf                          # Root orchestration file
├── variables.tf                     # Input variable definitions
├── outputs.tf                       # Output value definitions
├── provider.tf                      # AWS provider configuration
├── versions.tf                      # Terraform version constraints
├── terraform.tfvars.example         # Example variable values
├── vpc_infrastructure_dr_summary.md # Infrastructure documentation
├── MULTI_ENVIRONMENT_SETUP.md       # Environment setup guide
├── REQUEST_FLOW_DOCUMENTATION.md    # This file
├── environments/                    # Environment-specific configurations
│   ├── dr.json                     # DR environment config
│   ├── stage.json                  # Staging environment config
│   └── prod.json                   # Production environment config
├── modules/                         # Local module definitions
│   ├── network/                    # Networking modules
│   │   ├── vpc/                   # VPC creation module
│   │   └── networking/            # Advanced networking module
│   └── solr_stack_dr/             # Solr infrastructure module
│       ├── main.tf               # Solr module orchestration
│       ├── variables.tf          # Solr module inputs
│       └── outputs.tf            # Solr module outputs
├── user_data/                      # Instance initialization scripts
│   ├── solr_dr.sh                 # DR environment user data
│   ├── solr_stage.sh              # Stage environment user data
│   └── solr_prod.sh               # Prod environment user data
└── backup_resources/               # Resource backup configurations
```

## Data Flow Sequence

### 1. Initialization Phase
```
User Command: terraform plan/apply -var="environment=dr"
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 1: Environment Resolution                              │
│ ─────────────────────────────────────────────────────────── │
│ • Check var.environment (if provided)                      │
│ • Fall back to terraform.workspace                         │
│ • Result: local.environment = "dr"                         │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
┌─────────────────────────────────────────────────────────────┐
│ STEP 2: Configuration Loading                               │
│ ─────────────────────────────────────────────────────────── │
│ • Load: /environments/dr.json                              │
│ • Parse JSON into local.current_env                        │
│ • Available configs: VPC, networking, Solr, tags          │
└─────────────────────────────────────────────────────────────┘
```

### 2. Module Execution Sequence

#### Phase 1: VPC Foundation (No Dependencies)
```
┌─────────────────────────────────────────────────────────────┐
│ VPC MODULE EXECUTION                                        │
│ ─────────────────────────────────────────────────────────── │
│ Source: ./modules/network/vpc                               │
│                                                             │
│ Inputs (from dr.json):                                      │
│ • vpc_name: "vpc-dr"                                        │
│ • vpc_cidr: "10.200.48.0/20"                              │
│ • tags: { Environment: "dr", ... }                         │
│                                                             │
│ Creates:                                                    │
│ • AWS VPC with specified CIDR                              │
│ • DHCP options set                                          │
│ • DNS resolution enabled                                    │
│                                                             │
│ Outputs:                                                    │
│ • vpc_id → Used by solr_stack and networking modules       │
│ • cidr_block → Used for security group rules               │
└─────────────────────────────────────────────────────────────┘
```

#### Phase 2: Solr Stack Infrastructure (Depends on VPC)
```
┌─────────────────────────────────────────────────────────────┐
│ SOLR STACK MODULE EXECUTION                                 │
│ ─────────────────────────────────────────────────────────── │
│ Source: ./modules/solr_stack_dr                             │
│                                                             │
│ Inputs:                                                     │
│ • vpc_id: module.vpc.vpc_id                                │
│ • vpc_cidr_block: module.vpc.cidr_block                    │
│ • Environment configs from dr.json                          │
│                                                             │
│ Creates (using reusable modules):                           │
│ • 4 Subnets (3 private + 1 public)                        │
│ • Security Groups (solr-zk-sg)                            │
│ • Application Load Balancer                                 │
│ • Auto Scaling Group                                        │
│ • EFS File System                                          │
│ • S3 Backup Bucket                                         │
│ • IAM Roles and Policies                                   │
│ • Route Tables (privateSolrRouteTable, publicSOLRRouteTable)│
│                                                             │
│ Outputs:                                                    │
│ • solr_public_subnet_ids → Used by networking module       │
│ • solr_private_subnet_ids → Used by networking module      │
│ • Security group IDs, ALB details, etc.                   │
└─────────────────────────────────────────────────────────────┘
```

#### Phase 3: Advanced Networking (Depends on VPC + Solr Stack)
```
┌─────────────────────────────────────────────────────────────┐
│ NETWORKING MODULE EXECUTION                                 │
│ ─────────────────────────────────────────────────────────── │
│ Source: ./modules/network/networking                        │
│                                                             │
│ Inputs:                                                     │
│ • vpc_id: module.vpc.vpc_id                                │
│ • public_subnet_ids: module.solr_stack.solr_public_subnet_ids │
│ • tgw_subnet_ids: module.solr_stack.solr_private_subnet_ids  │
│                                                             │
│ Creates:                                                    │
│ • Internet Gateway                                          │
│ • NAT Gateways (in public subnets)                        │
│ • Transit Gateway                                           │
│ • TGW Route Tables                                          │
│ • Cross-VPC connectivity                                    │
│                                                             │
│ Outputs:                                                    │
│ • internet_gateway_id → Used by solr_stack routing         │
│ • nat_gateway_ids → Used by solr_stack routing             │
│ • Transit Gateway details                                   │
└─────────────────────────────────────────────────────────────┘
```

### 3. Circular Dependency Resolution

The architecture has an intentional circular dependency that's resolved through Terraform's dependency management:

```
VPC Module
    │
    ▼ (vpc_id)
Solr Stack Module ←──────────────────────┐
    │                                    │
    ▼ (subnet_ids)                      │ (gateway_ids)
Networking Module                        │
    │                                    │
    └────────────────────────────────────┘

Resolution: depends_on = [module.solr_stack] in networking module
```

## Environment Configuration System

### JSON Configuration Structure
Each environment file (`/environments/{env}.json`) contains:

```json
{
  "name_prefix": "dr-preprod",
  "region": "us-west-2",
  "vpc_name": "vpc-dr",
  "vpc_cidr": "10.200.48.0/20",
  "solr_name_prefix": "dr-solr",
  "solr_subnet_cidr_base": "10.200.58.0/24",
  "solr_instance_type": "m5.xlarge",
  "solr_cluster_size": 3,
  "create_igw": true,
  "create_nat_gateways": true,
  "nat_gateway_count": 1,
  "create_tgw": true,
  "common_tags": {
    "Environment": "dr",
    "Project": "it-web-dr",
    "ManagedBy": "terraform"
  }
}
```

### Environment Selection Methods

1. **Explicit Variable**: `terraform apply -var="environment=dr"`
2. **Workspace**: `terraform workspace select dr && terraform apply`
3. **Default**: Falls back to "default" workspace

## Reusable Module Integration

### External Module Dependencies
The project uses standardized modules from `/it-web-terraform-modules/`:

```
Solr Stack Module Uses:
├── vpc (for subnet creation)
├── security_group (for solr-zk-sg)
├── alb (for load balancing)
├── IAM (for instance roles)
├── S3 (for backup storage)
└── autoscaling (for cluster management)
```

### Module Communication Pattern
```
Root main.tf
    │
    ├── Passes environment configs to modules
    │
    └── Modules communicate via outputs/inputs:
        • module.vpc.vpc_id → solr_stack.vpc_id
        • module.solr_stack.subnet_ids → networking.subnet_ids
        • module.networking.gateway_ids → solr_stack.gateway_ids
```

## User Data and Initialization

### Dynamic User Data Loading
```
user_data = templatefile("${path.module}/user_data/solr_${local.environment}.sh", {
  environment = local.environment,
  region      = local.current_env.region
})
```

This system:
1. Selects environment-specific initialization script
2. Passes runtime variables to the script
3. Enables environment-specific instance configuration

## Deployment Workflow

### Complete Deployment Sequence
```
1. terraform init
   └── Downloads providers and modules

2. terraform workspace select dr (optional)
   └── Sets workspace context

3. terraform plan -var="environment=dr"
   ├── Loads dr.json configuration
   ├── Resolves module dependencies
   ├── Plans VPC → Solr Stack → Networking
   └── Shows resource creation plan

4. terraform apply
   ├── Creates VPC foundation
   ├── Deploys Solr infrastructure
   ├── Configures advanced networking
   └── Outputs connection details

5. Post-deployment
   ├── Solr cluster auto-configures via user data
   ├── Load balancer health checks activate
   └── Cross-VPC connectivity established
```

## Key Benefits of This Architecture

1. **Environment Consistency**: JSON configs ensure identical patterns across environments
2. **Module Reusability**: Standardized modules reduce duplication and improve maintainability
3. **Dependency Management**: Clear dependency chain prevents resource conflicts
4. **Scalability**: Easy to add new environments by creating new JSON files
5. **Operational Simplicity**: Single command deployment with environment selection

## Troubleshooting Common Issues

### Circular Dependency Errors
- **Cause**: Missing `depends_on` in networking module
- **Solution**: Ensure `depends_on = [module.solr_stack]` is present

### Environment Not Found
- **Cause**: Missing JSON file for specified environment
- **Solution**: Create `/environments/{env}.json` with required configuration

### Module Path Errors
- **Cause**: Incorrect paths to reusable modules
- **Solution**: Verify `/it-web-terraform-modules/` path accessibility

This architecture provides a robust, scalable foundation for disaster recovery infrastructure deployment across multiple environments while maintaining consistency and operational simplicity.
