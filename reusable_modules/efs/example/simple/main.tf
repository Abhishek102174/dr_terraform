# EFS file system example
module "efs" {
  source = "../../"

  name             = "it-web-${var.environment}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  create_kms_key   = true
  
  subnet_ids         = var.subnet_ids
  security_group_ids = var.security_group_ids
  
  # Access points for different applications
  access_points = {
    webapp = {
      posix_user = {
        gid = 1000
        uid = 1000
      }
      root_directory = {
        path = "/webapp"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
    shared = {
      root_directory = {
        path = "/shared"
        creation_info = {
          owner_gid   = 1000
          owner_uid   = 1000
          permissions = "755"
        }
      }
    }
  }
  
  # Lifecycle policy for cost optimization
  lifecycle_policy = {
    transition_to_ia = "AFTER_30_DAYS"
  }
  
  enable_backup_policy = true
  
  tags = {
    Environment = var.environment
    Terraform   = "true"
    Project     = "it-web-${var.environment}-efs"
  }
}