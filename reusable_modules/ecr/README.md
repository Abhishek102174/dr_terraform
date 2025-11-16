# ECR Terraform Module

This module creates AWS ECR repositories with comprehensive ECR features and lifecycle management.

## Features

- Create multiple ECR repositories with a single module call
- Support for both **private** and **public** repositories
- Support for both mutable and immutable image tags
- Image vulnerability scanning on push (BASIC and ENHANCED)
- KMS encryption support (private repositories only)
- Repository access policies and registry-level policies
- Lifecycle policies for image management
- **Registry scanning configuration** with custom rules
- **Cross-region/cross-account replication**
- **Pull-through cache rules** for upstream registries
- Enhanced public repository catalog data
- Force delete option for repositories
- **IAM roles and policies** for ECR access (pull/push)
- Comprehensive tagging support

## Usage

```hcl
# Private ECR repositories
module "ecr_private" {
  source = "./modules/ecr"

  repository_names = [
    "my-app",
    "my-worker",
    "my-api"
  ]

  repository_type      = "private"
  image_tag_mutability = "MUTABLE"
  scan_on_push        = true
  encryption_type     = "AES256"

  tags = {
    Environment = "production"
    Project     = "my-project"
    Team        = "platform"
  }
}

# Public ECR repositories
module "ecr_public" {
  source = "./modules/ecr"

  repository_names = ["my-public-app"]
  repository_type  = "public"
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    Visibility  = "public"
  }
}

# ECR with IAM roles
module "ecr_with_iam" {
  source = "./modules/ecr"

  repository_names = ["my-app-with-iam"]
  repository_type  = "private"
  
  # Create IAM roles
  create_pull_role = true
  create_push_role = true
  
  # Customize trusted services
  pull_role_trusted_services = [
    "ecs-tasks.amazonaws.com",
    "lambda.amazonaws.com",
    "ec2.amazonaws.com"
  ]
  
  push_role_trusted_services = [
    "codebuild.amazonaws.com"
  ]
  
  # Add additional policies
  pull_role_additional_policy_arns = [
    "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  ]
  
  tags = {
    Environment = "production"
    Project     = "my-project"
    IAM         = "enabled"
  }
}

module "ecr_with_policies" {
  source = "./modules/ecr"

  repository_names = ["secure-app"]
  
  repository_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowPull"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ]
      }
    ]
  })

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Environment = "production"
    Security    = "high"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.12.2 |
| aws | >= 5.40.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.40.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| repository_names | List of ECR repository names | `list(string)` | n/a | yes |
| repository_type | Type of ECR repository (private or public) | `string` | `"private"` | no |
| image_tag_mutability | Image tag mutability setting | `string` | `"MUTABLE"` | no |
| scan_on_push | Enable image scanning on push | `bool` | `true` | no |
| encryption_type | Encryption type for repository | `string` | `"AES256"` | no |
| kms_key_id | KMS key ID for encryption | `string` | `null` | no |
| repository_policy | Repository policy JSON | `string` | `null` | no |
| lifecycle_policy | Lifecycle policy JSON | `string` | `null` | no |
| create_pull_role | Create IAM role for ECR pull access | `bool` | `false` | no |
| create_push_role | Create IAM role for ECR push access | `bool` | `false` | no |
| pull_role_trusted_services | AWS services that can assume pull role | `list(string)` | `["ecs-tasks.amazonaws.com", "lambda.amazonaws.com"]` | no |
| push_role_trusted_services | AWS services that can assume push role | `list(string)` | `["codebuild.amazonaws.com"]` | no |
| push_role_trusted_principals | AWS principals that can assume push role | `list(string)` | `[]` | no |
| pull_role_additional_policy_arns | Additional policies for pull role | `list(string)` | `[]` | no |
| push_role_additional_policy_arns | Additional policies for push role | `list(string)` | `[]` | no |
| tags | Tags to apply to ECR resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| repository_arns | ARNs of the ECR repositories |
| repository_urls | URLs of the ECR repositories |
| registry_ids | Registry IDs of the ECR repositories |
| repository_names | Names of the ECR repositories |
| pull_role_arn | ARN of the ECR pull role |
| pull_role_name | Name of the ECR pull role |
| push_role_arn | ARN of the ECR push role |
| push_role_name | Name of the ECR push role |

## Features

- **Multiple repositories**: Create multiple ECR repositories in one module call
- **Image scanning**: Automatic vulnerability scanning on image push
- **Encryption**: Support for AES256 and KMS encryption
- **Access control**: Repository policies for cross-account access
- **Lifecycle management**: Automatic cleanup of old images
- **Tagging**: Comprehensive tagging support for all resources

## Integration with Other Modules

### ECS Integration with IAM
```hcl
module "ecr" {
  source = "./modules/ecr"
  repository_names = ["my-app"]
  create_pull_role = true
}

module "ecs" {
  source = "./modules/ECS"
  container_image = module.ecr.repository_urls["my-app"]
  task_role_arn   = module.ecr.pull_role_arn
}
```

### Lambda Integration with IAM
```hcl
module "ecr" {
  source = "./modules/ecr"
  repository_names = ["my-function"]
  create_pull_role = true
  pull_role_trusted_services = ["lambda.amazonaws.com"]
}

module "lambda" {
  source = "./modules/Lambda"
  package_type = "Image"
  image_uri = "${module.ecr.repository_urls["my-function"]}:latest"
  role_arn = module.ecr.pull_role_arn
}
```

### CI/CD Integration
```hcl
module "ecr" {
  source = "./modules/ecr"
  repository_names = ["my-app"]
  create_push_role = true
  push_role_trusted_principals = [
    "arn:aws:iam::123456789012:user/ci-cd-user"
  ]
}

# Use module.ecr.push_role_arn in your CI/CD pipeline
```

### Complete ECR Setup with All Features
```hcl
module "ecr_complete" {
  source = "./modules/ecr"

  repository_names = ["my-app", "my-worker"]
  repository_type  = "private"
  force_delete     = true
  
  # Enhanced scanning
  registry_scan_type = "ENHANCED"
  registry_scan_rules = [
    {
      scan_frequency = "SCAN_ON_PUSH"
      repository_filter = {
        filter      = "my-app"
        filter_type = "WILDCARD"
      }
    }
  ]
  
  # Cross-region replication
  replication_configuration = [
    {
      destinations = [
        {
          region      = "us-east-1"
          registry_id = "123456789012"
        }
      ]
      repository_filters = [
        {
          filter      = "my-app"
          filter_type = "PREFIX_MATCH"
        }
      ]
    }
  ]
  
  # Pull-through cache
  pull_through_cache_rules = {
    "docker-hub" = {
      ecr_repository_prefix = "docker-hub"
      upstream_registry_url = "registry-1.docker.io"
    }
  }
  
  # Registry policy
  registry_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCrossAccountAccess"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::123456789012:root"
        }
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
      }
    ]
  })
  
  tags = {
    Environment = "production"
    Project     = "complete-setup"
  }
}
```