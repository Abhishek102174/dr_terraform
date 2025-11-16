# =============================================================================
# VPC MODULE - Using Reusable VPC Module
# =============================================================================
# Creates the base VPC infrastructure for DR environment using the reusable
# VPC module from it-web-terraform-modules repository
# =============================================================================

module "vpc" {
  source = "../../../../reusable_modules/vpc"

  name       = var.vpc_name
  cidr_block = var.vpc_cidr

  # Enable DNS for proper service discovery and resolution
  # Required for Solr cluster inter-node communication
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Don't create subnets, IGW, or NAT in this base VPC module
  # These will be handled by specific service modules
  create_igw         = false
  create_nat_gateway = false
  public_subnets     = []
  private_subnets    = []

  tags = merge(var.tags, {
    Purpose = "disaster-recovery-network"
    Service = "vpc"
    Type    = "dr-foundation"
  })
}
