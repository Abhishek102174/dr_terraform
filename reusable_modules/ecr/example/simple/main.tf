# Random suffix for unique repository names
resource "random_id" "suffix" {
  byte_length = 4
}

# Example: Private ECR repositories with lifecycle policy
module "ecr_private" {
  source = "../../"

  repository_names     = [for i in range(var.repository_count) : "${var.project_name}-app-${i + 1}-${random_id.suffix.hex}"]
  repository_type      = "private"
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
  encryption_type      = "AES256"
  force_delete         = var.force_delete

  # Lifecycle policy to manage image retention
  lifecycle_policy = var.lifecycle_policy_enabled ? jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last ${var.production_image_count} production images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["prod"]
          countType     = "imageCountMoreThan"
          countNumber   = var.production_image_count
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Delete untagged images older than ${var.untagged_image_days} day(s)"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = var.untagged_image_days
        }
        action = {
          type = "expire"
        }
      }
    ]
  }) : null

  # Create IAM roles for ECR access
  create_pull_role = var.create_iam_roles
  create_push_role = var.create_iam_roles

  tags = merge(var.tags, {
    Name = "${var.project_name}-private"
  })
}

# Example: Public ECR repository
module "ecr_public" {
  count  = var.enable_public_repository ? 1 : 0
  source = "../../"

  repository_names = ["${var.project_name}-public-${random_id.suffix.hex}"]
  repository_type  = "public"
  force_delete     = var.force_delete

  public_repository_catalog_data = {
    description       = "${var.project_name} public ECR repository"
    about_text        = "This is a demonstration of public ECR repository created with Terraform"
    usage_text        = "docker pull public.ecr.aws/your-registry/${var.project_name}-public-${random_id.suffix.hex}:latest"
    operating_systems = ["Linux"]
    architectures     = ["x86-64", "ARM 64"]
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-public"
  })
}