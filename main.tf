# =============================================================================
# DR TERRAFORM - MULTI-ENVIRONMENT INFRASTRUCTURE CONFIGURATION
# =============================================================================
# This is the root configuration file that orchestrates the deployment of
# disaster recovery infrastructure across multiple environments (dr, stage, prod).
# 
# ARCHITECTURE OVERVIEW:
# - Uses JSON-based environment configurations for scalability
# - Implements reusable modules from it-web-terraform-modules repository
# - Supports multi-environment deployment with consistent patterns
# - Provides complete DR infrastructure including VPC, networking, and Solr stack
# =============================================================================

# -----------------------------------------------------------------------------
# ENVIRONMENT CONFIGURATION MANAGEMENT
# -----------------------------------------------------------------------------
# Dynamic environment selection and configuration loading system that supports
# multiple deployment environments without code duplication.

locals {
  # Environment Selection Logic:
  # 1. Use explicit environment variable if provided
  # 2. Fall back to Terraform workspace name
  # This allows flexible deployment via: terraform workspace select <env>
  environment = var.environment != "" ? var.environment : terraform.workspace
  
  # Dynamic Configuration Loading from module-specific JSONs
  env_vpc  = jsondecode(file("${path.module}/environments/vpc/${local.environment}.json"))
  env_solr = jsondecode(file("${path.module}/environments/solr_stack_dr/${local.environment}.json"))
  env_net  = jsondecode(file("${path.module}/environments/network/${local.environment}.json"))
  current_env = merge(local.env_vpc, local.env_solr, local.env_net)
  region      = try(local.env_net.region, try(local.env_solr.region, "us-east-1"))
}

# =============================================================================
# VPC MODULE - FOUNDATIONAL NETWORK INFRASTRUCTURE
# =============================================================================
# Creates the Virtual Private Cloud (VPC) that serves as the foundation for all
# other infrastructure components. This module uses the reusable VPC module from
# it-web-terraform-modules to ensure consistency across environments.
#
# DATA FLOW: Environment JSON → Local Variables → VPC Module
# OUTPUTS: vpc_id, cidr_block (consumed by networking and solr_stack modules)

module "vpc" {
  source = "./modules/network/vpc"

  # Environment-specific VPC configuration loaded from JSON
  vpc_name = local.current_env.vpc_name  # e.g., "vpc-dr", "vpc-stage", "vpc-prod"
  vpc_cidr = local.current_env.vpc_cidr  # e.g., "10.200.48.0/20"
  tags     = local.current_env.common_tags  # Standardized tagging from JSON config
}

# =============================================================================
# NETWORKING MODULE - ADVANCED NETWORK COMPONENTS
# =============================================================================
# Deploys advanced networking components including Internet Gateway, NAT Gateways,
# and Transit Gateway for cross-VPC connectivity. This module depends on both
# VPC and Solr Stack modules to establish proper network routing.
#
# DEPENDENCY CHAIN: VPC → Solr Stack → Networking
# DATA FLOW: VPC outputs + Solr subnet outputs → Networking configuration
# OUTPUTS: gateway IDs, route table IDs (consumed by other modules)

module "networking" {
  source = "./modules/network/networking"
  
  # Base configuration from environment JSON
  name_prefix = local.current_env.name_prefix  # e.g., "dr-preprod", "stage-preprod"
  vpc_id      = module.vpc.vpc_id  # VPC dependency - must exist first
  
  # Internet Gateway Configuration
  # Controls whether to create IGW for internet access (typically true for all envs)
  create_igw = local.current_env.create_igw
  
  # NAT Gateway Configuration for Private Subnet Internet Access
  # Enables outbound internet connectivity for private subnets
  create_nat_gateways = local.current_env.create_nat_gateways  # Boolean flag
  nat_gateway_count   = local.current_env.nat_gateway_count    # Number of NAT GWs
  public_subnet_ids   = length(local.current_env.public_subnet_ids) > 0 ? local.current_env.public_subnet_ids : module.solr_stack.solr_public_subnet_ids
  
  # Transit Gateway Configuration for Cross-VPC Connectivity
  # Enables communication between different VPCs and on-premises networks
  create_tgw                           = local.current_env.create_tgw
  tgw_description                      = "${local.current_env.name_prefix} Transit Gateway for cross-VPC connectivity"
  tgw_default_route_table_association  = "enable"  # Auto-associate new attachments
  tgw_default_route_table_propagation  = "enable"  # Auto-propagate routes
  tgw_subnet_ids      = length(local.current_env.tgw_subnet_ids) > 0 ? local.current_env.tgw_subnet_ids : module.solr_stack.solr_private_subnet_ids
  create_tgw_route_table = local.current_env.create_tgw
  
  # Standardized resource tagging
  common_tags = local.current_env.common_tags
  

}

# =============================================================================
# SOLR STACK MODULE - APPLICATION INFRASTRUCTURE
# =============================================================================
# Deploys the complete Solr search cluster infrastructure including subnets,
# security groups, load balancers, auto-scaling groups, EFS storage, and S3 backups.
# This module represents the core application infrastructure for the DR environment.
#
# ARCHITECTURE COMPONENTS:
# - 3 Private Subnets + 1 Public Subnet (matching production layout)
# - Security Groups with complex rules for Solr, Zookeeper, EFS, and monitoring
# - Application Load Balancer for high availability
# - Auto Scaling Group for dynamic capacity management
# - EFS for shared storage and S3 for backups
# - IAM roles and policies for secure operations
#
# DATA FLOW: VPC outputs → Solr configuration → Networking inputs
# OUTPUTS: subnet IDs, security group IDs, ALB details (consumed by networking module)

module "solr_stack" {
  source = "./modules/solr_stack_dr"
  
  # Base Infrastructure Configuration
  name_prefix       = local.current_env.name_prefix
  vpc_id           = module.vpc.vpc_id                        # VPC dependency
  vpc_cidr_block   = module.vpc.cidr_block                    # VPC CIDR for security rules
  subnet_cidr_base = local.current_env.subnet_cidr_base  # Base CIDR for Solr subnets
  
  # SSH Access Configuration
  key_name         = var.solr_key_name     # EC2 Key Pair for instance access
  solr_private_key  = var.solr_private_key  # Private key content for SSH
  
  # AMI Configuration
  solr_fallback_ami_id = local.current_env.solr_fallback_ami_id  # Fallback AMI from environment JSON
  
  # Networking Dependencies (provided by networking module)
  # These create a circular dependency that's resolved via depends_on
  internet_gateway_id = try(module.networking.internet_gateway_id, "")
  nat_gateway_ids     = try(module.networking.nat_gateway_ids, [])
  
  # Environment-Specific Instance Configuration
  instance_type     = local.current_env.instance_type
  cluster_size      = local.current_env.cluster_size
  data_volume_size  = local.current_env.data_volume_size
  data_volume_iops  = local.current_env.data_volume_iops
  
  # Operational Configuration
  health_check_grace_period  = local.current_env.health_check_grace_period   # ASG health check delay
  enable_deletion_protection = local.current_env.enable_deletion_protection  # ALB protection
  
  # Environment-Specific User Data Script
  # Dynamically loads environment-specific initialization script
  user_data = templatefile("${path.module}/user_data/solr_${local.environment}.sh", {
    environment = local.environment                    # Current environment name
    region      = local.region
  })
  
  # Comprehensive Resource Tagging
  # Combines environment tags with module-specific metadata
  common_tags = merge(local.current_env.common_tags, {
    Purpose      = "${local.environment}-solr-cluster"
    Region       = local.region
    SourceRegion = "us-east-1"
    Service      = "solr"
  })
}
