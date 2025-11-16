provider "aws" {
  region = var.aws_region
}

# Data sources for assume role policies
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "github_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:${var.github_repo}:*"]
    }
  }
}

# Create GitHub OIDC Provider first (needed for assume role policy)
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com",
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name = "github-actions"
  }
}

# Example IAM policies
data "aws_iam_policy_document" "developer_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::dev-bucket/*",
      "arn:aws:s3:::dev-bucket"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
      "ec2:DescribeImages"
    ]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "readonly_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::readonly-bucket/*",
      "arn:aws:s3:::readonly-bucket"
    ]
  }
}

# Use the IAM module
module "iam" {
  source = "../../"

  namespace   = var.namespace
  environment = var.environment
  stage       = var.stage
  name        = var.name

  # IAM Users
  users = {
    "john-developer" = {
      path = "/developers/"
      tags = {
        Department = "Engineering"
        Role       = "Developer"
      }
    }
    "jane-admin" = {
      path = "/admins/"
      tags = {
        Department = "IT"
        Role       = "Administrator"
      }
    }
    "bob-readonly" = {
      force_destroy = true
      tags = {
        Department = "Analytics"
        Role       = "Analyst"
      }
    }
  }

  # IAM Groups
  groups = {
    "developers" = {
      path = "/groups/"
    }
    "administrators" = {
      path = "/groups/"
    }
    "readonly-users" = {}
  }

  # Group Memberships
  group_memberships = {
    "developers-membership" = {
      group = "developers"
      users = ["john-developer"]
    }
    "admins-membership" = {
      group = "administrators"
      users = ["jane-admin"]
    }
    "readonly-membership" = {
      group = "readonly-users"
      users = ["bob-readonly"]
    }
  }

  # IAM Roles
  roles = {
    "ec2-instance-role" = {
      assume_role_policy   = data.aws_iam_policy_document.ec2_assume_role.json
      description          = "Role for EC2 instances"
      max_session_duration = 7200
      permissions_boundary = "arn:aws:iam::aws:policy/PowerUserAccess"
      tags = {
        Purpose = "EC2"
      }
    }
    "github-actions-role" = {
      assume_role_policy = data.aws_iam_policy_document.github_assume_role.json
      description        = "Role for GitHub Actions CI/CD"
      tags = {
        Purpose = "CI/CD"
        Source  = "GitHub"
      }
    }
  }

  # Managed Policies
  managed_policies = {
    "developer-policy" = {
      description = "Policy for developers with S3 and EC2 read access"
      policy      = data.aws_iam_policy_document.developer_policy.json
      path        = "/policies/"
      tags = {
        PolicyType = "Custom"
        Department = "Engineering"
      }
    }
    "readonly-policy" = {
      description = "Read-only policy for S3"
      policy      = data.aws_iam_policy_document.readonly_policy.json
    }
  }

  # Policy Attachments
  group_policy_attachments = {
    "developers-custom-policy" = {
      group      = "developers"
      policy_arn = "developer-policy" # Will be resolved to full ARN
    }
    "developers-managed-policy" = {
      group      = "administrators"
      policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
    }
    "readonly-policy-attachment" = {
      group      = "readonly-users"
      policy_arn = "readonly-policy"
    }
  }

  role_policy_attachments = {
    "ec2-role-policy" = {
      role       = "ec2-instance-role"
      policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    "github-role-policy" = {
      role       = "github-actions-role"
      policy_arn = "developer-policy"
    }
  }

  # Inline Policies
  role_inline_policies = {
    "ec2-cloudwatch-logs" = {
      role = "ec2-instance-role"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Effect = "Allow"
            Action = [
              "logs:CreateLogGroup",
              "logs:CreateLogStream",
              "logs:PutLogEvents",
              "logs:DescribeLogStreams"
            ]
            Resource = "arn:aws:logs:*:*:*"
          }
        ]
      })
    }
  }

  # OIDC Identity Providers (Additional ones beyond GitHub)
  oidc_identity_providers = {
    "example-oidc" = {
      url             = "https://oidc.example.com"
      client_id_list  = ["example-client"]
      thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
      tags = {
        Provider = "Example"
      }
    }
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
