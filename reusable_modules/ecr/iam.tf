# ECR Pull Role (for ECS, Lambda, EC2)
data "aws_iam_policy_document" "ecr_pull_assume_role" {
  count = var.create_pull_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = var.pull_role_trusted_services
    }
  }
}

resource "aws_iam_role" "ecr_pull_role" {
  count = var.create_pull_role ? 1 : 0

  name               = "${var.repository_names[0]}-ecr-pull-role"
  assume_role_policy = data.aws_iam_policy_document.ecr_pull_assume_role[0].json

  tags = merge(var.tags, {
    Name = "${var.repository_names[0]}-ecr-pull-role"
    Type = "ECR-Pull-Role"
  })
}

# ECR Pull Policy
data "aws_iam_policy_document" "ecr_pull_policy" {
  count = var.create_pull_role ? 1 : 0

  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = var.repository_type == "private" ? [
      for repo in aws_ecr_repository.private : repo.arn
    ] : []
  }
}

resource "aws_iam_role_policy" "ecr_pull_policy" {
  count = var.create_pull_role ? 1 : 0

  name   = "${var.repository_names[0]}-ecr-pull-policy"
  role   = aws_iam_role.ecr_pull_role[0].id
  policy = data.aws_iam_policy_document.ecr_pull_policy[0].json
}

# ECR Push Role (for CI/CD)
data "aws_iam_policy_document" "ecr_push_assume_role" {
  count = var.create_push_role ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = var.push_role_trusted_services
    }
  }

  dynamic "statement" {
    for_each = length(var.push_role_trusted_principals) > 0 ? [1] : []
    content {
      actions = ["sts:AssumeRole"]
      principals {
        type        = "AWS"
        identifiers = var.push_role_trusted_principals
      }
    }
  }
}

resource "aws_iam_role" "ecr_push_role" {
  count = var.create_push_role ? 1 : 0

  name               = "${var.repository_names[0]}-ecr-push-role"
  assume_role_policy = data.aws_iam_policy_document.ecr_push_assume_role[0].json

  tags = merge(var.tags, {
    Name = "${var.repository_names[0]}-ecr-push-role"
    Type = "ECR-Push-Role"
  })
}

# ECR Push Policy
data "aws_iam_policy_document" "ecr_push_policy" {
  count = var.create_push_role ? 1 : 0

  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = ["*"]
  }

  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload"
    ]
    resources = var.repository_type == "private" ? [
      for repo in aws_ecr_repository.private : repo.arn
    ] : []
  }
}

resource "aws_iam_role_policy" "ecr_push_policy" {
  count = var.create_push_role ? 1 : 0

  name   = "${var.repository_names[0]}-ecr-push-policy"
  role   = aws_iam_role.ecr_push_role[0].id
  policy = data.aws_iam_policy_document.ecr_push_policy[0].json
}

# Attach additional policy ARNs to pull role
resource "aws_iam_role_policy_attachment" "pull_role_additional_policies" {
  for_each = var.create_pull_role ? toset(var.pull_role_additional_policy_arns) : []

  role       = aws_iam_role.ecr_pull_role[0].name
  policy_arn = each.value
}

# Attach additional policy ARNs to push role
resource "aws_iam_role_policy_attachment" "push_role_additional_policies" {
  for_each = var.create_push_role ? toset(var.push_role_additional_policy_arns) : []

  role       = aws_iam_role.ecr_push_role[0].name
  policy_arn = each.value
}