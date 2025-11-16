# Simple Solr Stack DR Example

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Deploy Solr DR stack
module "solr_dr_example" {
  source = "../../"
  
  name_prefix = var.name_prefix
  vpc_cidr    = var.vpc_cidr
  key_name    = var.key_name
  
  # Instance configuration
  instance_type     = var.instance_type
  cluster_size      = var.cluster_size
  data_volume_size  = var.data_volume_size
  data_volume_iops  = var.data_volume_iops
  
  # Operational settings
  health_check_grace_period  = var.health_check_grace_period
  enable_deletion_protection = var.enable_deletion_protection
  
  common_tags = var.common_tags
}

# Outputs
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.solr_dr_example.vpc_id
}

output "load_balancer_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.solr_dr_example.load_balancer_dns_name
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group"
  value       = module.solr_dr_example.autoscaling_group_name
}

output "solr_admin_url" {
  description = "Solr admin interface URL"
  value       = "http://${module.solr_dr_example.load_balancer_dns_name}:8983/solr/"
}
