# =============================================================================
# SOLR STACK DR MODULE - Using Reusable Terraform Modules
# =============================================================================
# This module creates Solr-specific infrastructure using reusable modules from
# ../../../reusable_modules repository
# =============================================================================

# -----------------------------------------------------------------------------
# KEY PAIR CREATION - Create key pair from private key
# -----------------------------------------------------------------------------

# Extract public key from private key using external data source
data "external" "public_key" {
  program = ["bash", "-c", "echo '{\"public_key\":\"'$(ssh-keygen -y -f <(echo \"${var.solr_private_key}\"))'\"}' "]
}

# Create key pair in AWS
resource "aws_key_pair" "solr_key" {
  key_name   = var.key_name
  public_key = data.external.public_key.result.public_key
  
  tags = merge(var.common_tags, {
    Name    = var.key_name
    Service = "solr"
    Purpose = "solr-cluster-ssh-access"
  })
}

# -----------------------------------------------------------------------------
# DATA SOURCES - Discovery of existing AWS resources
# -----------------------------------------------------------------------------

# Find the latest Solr AMI for launching instances


# Local to handle AMI selection with fallback logic
locals {
  selected_ami_id = var.ami_id != "" ? var.ami_id : var.solr_fallback_ami_id
}

# Get available AZs for multi-zone Solr cluster deployment
data "aws_availability_zones" "available" {
  state = "available"
}

# -----------------------------------------------------------------------------
# SUBNETS AND ROUTING - Using reusable VPC module components
# -----------------------------------------------------------------------------

# IAM assume role policy for EC2
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Solr-specific subnets using VPC module pattern (matching actual infrastructure)
# Solr-specific subnets in existing VPC
resource "aws_subnet" "solr_public" {
  vpc_id                  = var.vpc_id
  cidr_block              = "10.200.59.128/28"
  availability_zone       = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-public-solr-1"
    Type = "Public"
    Service = "solr"
  })
}

resource "aws_subnet" "solr_private" {
  count             = 3
  vpc_id            = var.vpc_id
  cidr_block        = element(["10.200.58.0/25", "10.200.58.128/25", "10.200.59.0/25"], count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-private-solr-${count.index + 1}"
    Type = "Private"
    Service = "solr"
  })
}

# Custom route tables for Solr subnets (matching actual infrastructure)
# Public Solr Route Table (publicSOLRRouteTable)
resource "aws_route_table" "solr_public_rt" {
  vpc_id = var.vpc_id
  
  dynamic "route" {
    for_each = var.internet_gateway_id != "" ? [var.internet_gateway_id] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = route.value
    }
  }
  
  # Add Transit Gateway routes if provided
  dynamic "route" {
    for_each = var.transit_gateway_routes
    content {
      cidr_block         = route.value.cidr_block
      transit_gateway_id = route.value.transit_gateway_id
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-publicSOLRRouteTable"
    Purpose = "solr-public-routing"
  })
}

resource "aws_route_table_association" "solr_public_rta" {
  subnet_id      = aws_subnet.solr_public.id
  route_table_id = aws_route_table.solr_public_rt.id
}

# Private Solr Route Table (privateSolrRouteTable) - shared by all 3 private subnets
resource "aws_route_table" "solr_private_rt" {
  vpc_id = var.vpc_id
  
  dynamic "route" {
    for_each = length(var.nat_gateway_ids) > 0 ? [var.nat_gateway_ids[0]] : []
    content {
      cidr_block     = "0.0.0.0/0"
      nat_gateway_id = route.value
    }
  }
  
  # Add Transit Gateway routes if provided
  dynamic "route" {
    for_each = var.transit_gateway_routes
    content {
      cidr_block         = route.value.cidr_block
      transit_gateway_id = route.value.transit_gateway_id
    }
  }
  
  # Add VPC Peering routes if provided
  dynamic "route" {
    for_each = var.vpc_peering_routes
    content {
      cidr_block                = route.value.cidr_block
      vpc_peering_connection_id = route.value.vpc_peering_connection_id
    }
  }
  
  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-privateSolrRouteTable"
    Purpose = "solr-cluster-outbound-routing"
  })
}

resource "aws_route_table_association" "solr_private_rta" {
  count = 3  # All 3 private subnets use the same route table
  
  subnet_id      = aws_subnet.solr_private[count.index].id
  route_table_id = aws_route_table.solr_private_rt.id
}

# -----------------------------------------------------------------------------
# SECURITY GROUPS - Using reusable security group module
# -----------------------------------------------------------------------------

# Security group for Solr cluster instances (matching actual solr-zk-sg)
module "solr_security_group" {
  source = "../../reusable_modules/security_group"
  
  name        = "${var.name_prefix}-solr-zk-sg"
  description = "Security group for Solr and Zookeeper cluster instances"
  vpc_id      = var.vpc_id
  
  ingress_rules = [
    # SSH access from multiple on-premises networks
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.on_premises_cidrs
      description = "SSH access from Waters On-premises & VPN networks"
    },
    # SSH access from within security group and services
    {
      from_port                = 22
      to_port                  = 22
      protocol                 = "tcp"
      source_security_group_id = "self"
      description              = "SSH access from solr_zk security group"
    },
    # Solr web interface (8983)
    {
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      cidr_blocks = concat(var.on_premises_cidrs, var.cross_environment_cidrs)
      description = "Solr web interface and API access"
    },
    # Solr access from within security group and other services
    {
      from_port                = 8983
      to_port                  = 8983
      protocol                 = "tcp"
      source_security_group_id = "self"
      description              = "Solr access from within cluster"
    },
    # Zookeeper coordination (2181)
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      cidr_blocks = var.cross_environment_cidrs
      description = "Zookeeper access for cross-environment indexing"
    },
    # Zookeeper access from within security group
    {
      from_port                = 2181
      to_port                  = 2181
      protocol                 = "tcp"
      source_security_group_id = "self"
      description              = "Zookeeper access from within cluster"
    },
    # Zookeeper cluster communication (2888-3888)
    {
      from_port                = 2888
      to_port                  = 3888
      protocol                 = "tcp"
      source_security_group_id = "self"
      description              = "Zookeeper cluster communication"
    },
    # EFS access (2049)
    {
      from_port                = 2049
      to_port                  = 2049
      protocol                 = "tcp"
      source_security_group_id = "self"
      description              = "EFS share access for Solr cluster"
    },
    # Monit web interface (2812)
    {
      from_port   = 2812
      to_port     = 2812
      protocol    = "tcp"
      cidr_blocks = ["10.231.0.0/16", "10.216.0.0/16"]
      description = "Monit web interface access"
    }
  ]
  
  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "All outbound traffic for Solr cluster operations"
    }
  ]
  
  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-solr-zk-sg"
    Service = "solr"
    Purpose = "solr-zookeeper-cluster-security"
  })
}

# -----------------------------------------------------------------------------
# APPLICATION LOAD BALANCER - Using reusable ALB module
# -----------------------------------------------------------------------------

# Application Load Balancer for Solr cluster
module "solr_alb" {
  source = "../../reusable_modules/alb"
  
  name               = "${var.name_prefix}-solr-alb"
  internal           = true
  lb_type            = "application"
  vpc_id             = var.vpc_id
  subnet_ids         = aws_subnet.solr_private[*].id
  
  security_group_rules = [
    {
      type        = "ingress"
      from_port   = 8983
      to_port     = 8983
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr_block]
    },
    {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  
  target_groups = {
    solr = {
      name     = "${var.name_prefix}-solr-tg"
      port     = 8983
      protocol = "HTTP"
      health_check = {
        path                = "/solr/admin/info/system"
        interval            = 30
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
        matcher             = "200"
      }
    }
  }
  
  listeners = {
    http_8983 = {
      port     = 8983
      protocol = "HTTP"
      default_action = {
        type = "forward"
        forward = {
          target_groups = [
            { arn = "solr" }
          ]
        }
      }
    }
  }
  
  enable_deletion_protection = var.enable_deletion_protection
  
  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-solr-cluster-alb"
    Service = "solr"
    Purpose = "solr-cluster-load-balancing"
  })
}

# -----------------------------------------------------------------------------
# IAM CONFIGURATION - Using reusable IAM module
# -----------------------------------------------------------------------------

# IAM role for Solr cluster
module "solr_iam" {
  source = "../../reusable_modules/IAM"

  roles = {
    "${var.name_prefix}-solr-cluster-role" = {
      assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
      description        = "Role for Solr cluster EC2 instances"
      tags               = merge(var.common_tags, { Service = "solr" })
    }
  }

  role_policy_attachments = {
    "solr-ssm" = {
      role       = "${var.name_prefix}-solr-cluster-role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
  }
}

resource "aws_iam_instance_profile" "solr" {
  name = "${var.name_prefix}-solr-instance-profile"
  role = "${var.name_prefix}-solr-cluster-role"
  depends_on = [module.solr_iam]
}

# -----------------------------------------------------------------------------
# EFS FILE SYSTEM - For shared Solr data storage
# -----------------------------------------------------------------------------

# EFS file system for Solr cluster shared storage
resource "aws_efs_file_system" "solr_efs" {
  creation_token = "${var.name_prefix}-solr-efs"
  
  performance_mode = "generalPurpose"
  throughput_mode  = "provisioned"
  provisioned_throughput_in_mibps = var.efs_provisioned_throughput
  
  encrypted = true
  
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-solr-efs"
    Service = "solr"
    Purpose = "solr-shared-storage"
  })
}

# EFS mount targets in each Solr subnet
resource "aws_efs_mount_target" "solr_efs_mount" {
  count = 3
  
  file_system_id  = aws_efs_file_system.solr_efs.id
  subnet_id       = aws_subnet.solr_private[count.index].id
  security_groups = [module.solr_security_group.security_group_id]
}

# -----------------------------------------------------------------------------
# S3 BUCKET - Using reusable S3 module for Solr backups
# -----------------------------------------------------------------------------

module "solr_backup_bucket" {
  source = "../../reusable_modules/S3"

  buckets = {
    "solr-backups" = {
      bucket_name        = "${var.name_prefix}-solr-backups"
      tags               = merge(var.common_tags, { Service = "solr", Purpose = "solr-backup-storage" })
      block_public_access = true
      versioning_enabled = true
      encryption_enabled = true
      sse_algorithm      = "AES256"
      lifecycle_rules = {
        solr_backup_lifecycle = {
          enabled         = true
          expiration_days = 90
        }
      }
    }
  }
}

# -----------------------------------------------------------------------------
# AUTO SCALING GROUP - Using reusable autoscaling module
# -----------------------------------------------------------------------------

module "solr_autoscaling" {
  source = "../../reusable_modules/autoscaling"
  
  name_prefix = "${var.name_prefix}-solr"
  vpc_id      = var.vpc_id
  
  # Launch template configuration
  ami_id       = local.selected_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  
  security_group_ids   = [module.solr_security_group.security_group_id]
  iam_instance_profile = aws_iam_instance_profile.solr.name
  
  user_data = var.user_data
  
  # Block device mappings
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size = var.root_volume_size
        volume_type = "gp3"
        encrypted   = true
      }
    },
    {
      device_name = "/dev/xvdf"
      ebs = {
        volume_size = var.data_volume_size
        volume_type = "gp3"
        iops        = var.data_volume_iops
        encrypted   = true
      }
    }
  ]
  
  # Auto Scaling Group configuration
  min_size                  = var.cluster_size
  max_size                  = var.cluster_size
  desired_capacity          = var.cluster_size
  subnet_ids                = aws_subnet.solr_private[*].id
  health_check_type         = "ELB"
  health_check_grace_period = var.health_check_grace_period
  
  target_group_arns = [module.solr_alb.target_group_arns["solr"]]
  
  tags = merge(var.common_tags, {
    Name    = "${var.name_prefix}-solr-cluster"
    Service = "solr"
    Purpose = "solr-cluster-compute"
  })
}
