# Multi-Environment Terraform Setup

## Overview
This Terraform configuration supports multiple environments (dr, stage, prod) with environment-specific configurations imported from separate files to avoid duplication.

## Architecture

### Clean Separation of Concerns
- **`main.tf`** - Core infrastructure modules and logic
- **`environments/dr.tf`** - DR environment configuration
- **`environments/stage.tf`** - Stage environment configuration  
- **`environments/prod.tf`** - Production environment configuration

### How It Works
```hcl
# main.tf imports configurations from environment files
locals {
  environment = var.environment != "" ? var.environment : terraform.workspace
  
  # Import environment-specific configuration
  current_env = local.environment == "dr" ? local.dr_config : (
    local.environment == "stage" ? local.stage_config : local.prod_config
  )
}
```

## Environment Configurations

### DR Environment (`environments/dr.tf`)
- **Purpose**: Disaster Recovery
- **VPC CIDR**: 10.200.48.0/20
- **Instance Type**: m5.xlarge
- **Cluster Size**: 3 nodes
- **Features**: Full DR capabilities, deletion protection enabled

### Stage Environment (`environments/stage.tf`)
- **Purpose**: Staging/Testing
- **VPC CIDR**: 10.210.48.0/20
- **Instance Type**: m5.large (smaller)
- **Cluster Size**: 2 nodes (smaller)
- **Features**: Cost-optimized, deletion protection disabled

### Prod Environment (`environments/prod.tf`)
- **Purpose**: Production
- **VPC CIDR**: 10.220.48.0/20
- **Instance Type**: m5.2xlarge (larger)
- **Cluster Size**: 5 nodes (larger)
- **Features**: High availability, Transit Gateway enabled

## Usage

### Method 1: Using Environment Variable
```bash
# Deploy DR environment
terraform apply -var="environment=dr"

# Deploy Stage environment
terraform apply -var="environment=stage"

# Deploy Production environment
terraform apply -var="environment=prod"
```

### Method 2: Using Terraform Workspaces
```bash
# Create and select workspace
terraform workspace new dr
terraform workspace select dr
terraform apply

# Switch to different environment
terraform workspace select stage
terraform apply
```

### Method 3: Using tfvars files
```bash
# Create environment-specific tfvars
echo 'environment = "dr"' > dr.tfvars
echo 'environment = "stage"' > stage.tfvars
echo 'environment = "prod"' > prod.tfvars

# Deploy specific environment
terraform apply -var-file="dr.tfvars"
```

## Key Benefits

### ✅ No Duplication
- Environment configurations are defined once in separate files
- Main configuration imports and uses the appropriate environment config
- Clean separation of infrastructure logic and environment-specific settings

### ✅ Easy Maintenance
- Add new environments by creating new files in `environments/`
- Modify environment settings without touching main infrastructure code
- Clear visibility of differences between environments

### ✅ Consistent Structure
- All environments follow the same configuration structure
- Standardized naming and tagging across environments
- Predictable resource organization

## File Structure
```
/mnt/c/dr_terraform/
├── main.tf                    # Core infrastructure (imports env configs)
├── variables.tf               # Input variables
├── outputs.tf                 # Environment-aware outputs
├── environments/
│   ├── dr.tf                 # DR configuration (local.dr_config)
│   ├── stage.tf              # Stage configuration (local.stage_config)
│   └── prod.tf               # Prod configuration (local.prod_config)
├── user_data/
│   ├── solr_dr.sh            # DR-specific user data
│   ├── solr_stage.sh         # Stage-specific user data
│   └── solr_prod.sh          # Prod-specific user data
└── modules/                   # Reusable modules
```

## Adding New Environments

1. Create new environment file: `environments/dev.tf`
2. Define `local.dev_config` with environment settings
3. Update main.tf to include the new environment in the conditional logic
4. Create corresponding user data script: `user_data/solr_dev.sh`

## Example Commands

```bash
# Initialize and plan for DR
terraform init
terraform workspace new dr
terraform plan -var="environment=dr"
terraform apply -var="environment=dr"

# Switch to staging
terraform workspace select stage
terraform plan -var="environment=stage"
terraform apply -var="environment=stage"

# Destroy specific environment
terraform workspace select dr
terraform destroy -var="environment=dr"
```
