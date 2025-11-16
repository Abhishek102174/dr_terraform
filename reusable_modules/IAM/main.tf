locals {
  # Generate consistent naming
  id = join(var.delimiter, compact([var.namespace, var.environment, var.stage, var.name]))
  
  # Merge tags
  tags = merge(var.tags, {
    Name        = local.id
    Environment = var.environment
    Stage       = var.stage
  })

  # Create a map of policy names to ARNs for policies created by this module
  managed_policy_arns = {
    for k, v in aws_iam_policy.managed_policies : k => v.arn
  }

  # Helper function to resolve policy ARN - if it starts with "arn:", use as-is, otherwise look up in our managed policies
  resolved_user_policy_attachments = {
    for k, v in var.user_policy_attachments : k => {
      user       = v.user
      policy_arn = startswith(v.policy_arn, "arn:") ? v.policy_arn : local.managed_policy_arns[v.policy_arn]
    }
  }

  resolved_group_policy_attachments = {
    for k, v in var.group_policy_attachments : k => {
      group      = v.group
      policy_arn = startswith(v.policy_arn, "arn:") ? v.policy_arn : local.managed_policy_arns[v.policy_arn]
    }
  }

  resolved_role_policy_attachments = {
    for k, v in var.role_policy_attachments : k => {
      role       = v.role
      policy_arn = startswith(v.policy_arn, "arn:") ? v.policy_arn : local.managed_policy_arns[v.policy_arn]
    }
  }
}

# IAM Users
resource "aws_iam_user" "users" {
  for_each = var.users

  name          = each.key
  path          = each.value.path
  force_destroy = each.value.force_destroy

  tags = merge(local.tags, each.value.tags, {
    Type = "IAM-User"
  })
}

# IAM Groups
resource "aws_iam_group" "groups" {
  for_each = var.groups

  name = each.key
  path = each.value.path
}

# Group Memberships
resource "aws_iam_group_membership" "group_memberships" {
  for_each = var.group_memberships

  name  = each.key
  group = each.value.group
  users = each.value.users

  depends_on = [aws_iam_user.users, aws_iam_group.groups]
}

# IAM Roles
resource "aws_iam_role" "roles" {
  for_each = var.roles

  name                  = each.key
  assume_role_policy    = each.value.assume_role_policy
  description           = each.value.description
  force_detach_policies = each.value.force_detach_policies
  max_session_duration  = each.value.max_session_duration
  path                  = each.value.path
  permissions_boundary  = each.value.permissions_boundary

  tags = merge(local.tags, each.value.tags, {
    Type = "IAM-Role"
  })
}

# Managed Policies
resource "aws_iam_policy" "managed_policies" {
  for_each = var.managed_policies

  name        = each.key
  description = each.value.description
  policy      = each.value.policy
  path        = each.value.path

  tags = merge(local.tags, each.value.tags, {
    Type = "IAM-Policy"
  })
}

# Policy Attachments - Users
resource "aws_iam_user_policy_attachment" "user_policy_attachments" {
  for_each = local.resolved_user_policy_attachments

  user       = each.value.user
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_user.users, aws_iam_policy.managed_policies]
}

# Policy Attachments - Groups
resource "aws_iam_group_policy_attachment" "group_policy_attachments" {
  for_each = local.resolved_group_policy_attachments

  group      = each.value.group
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_group.groups, aws_iam_policy.managed_policies]
}

# Policy Attachments - Roles
resource "aws_iam_role_policy_attachment" "role_policy_attachments" {
  for_each = local.resolved_role_policy_attachments

  role       = each.value.role
  policy_arn = each.value.policy_arn

  depends_on = [aws_iam_role.roles, aws_iam_policy.managed_policies]
}

# Inline Policies - Users
resource "aws_iam_user_policy" "user_inline_policies" {
  for_each = var.user_inline_policies

  name   = each.key
  user   = each.value.user
  policy = each.value.policy

  depends_on = [aws_iam_user.users]
}

# Inline Policies - Groups
resource "aws_iam_group_policy" "group_inline_policies" {
  for_each = var.group_inline_policies

  name   = each.key
  group  = each.value.group
  policy = each.value.policy

  depends_on = [aws_iam_group.groups]
}

# Inline Policies - Roles
resource "aws_iam_role_policy" "role_inline_policies" {
  for_each = var.role_inline_policies

  name   = each.key
  role   = each.value.role
  policy = each.value.policy

  depends_on = [aws_iam_role.roles]
}

# SAML Identity Providers
resource "aws_iam_saml_provider" "saml_providers" {
  for_each = var.saml_identity_providers

  name                   = each.key
  saml_metadata_document = each.value.saml_metadata_document

  tags = merge(local.tags, each.value.tags, {
    Type = "SAML-Provider"
  })
}

# OIDC Identity Providers
resource "aws_iam_openid_connect_provider" "oidc_providers" {
  for_each = var.oidc_identity_providers

  url             = each.value.url
  client_id_list  = each.value.client_id_list
  thumbprint_list = each.value.thumbprint_list

  tags = merge(local.tags, each.value.tags, {
    Type = "OIDC-Provider"
  })
}
