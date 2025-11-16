# User Outputs
output "users" {
  description = "Map of IAM users created"
  value = {
    for k, v in aws_iam_user.users : k => {
      arn           = v.arn
      name          = v.name
      path          = v.path
      unique_id     = v.unique_id
    }
  }
}

# Group Outputs
output "groups" {
  description = "Map of IAM groups created"
  value = {
    for k, v in aws_iam_group.groups : k => {
      arn       = v.arn
      name      = v.name
      path      = v.path
      unique_id = v.unique_id
    }
  }
}

# Role Outputs
output "roles" {
  description = "Map of IAM roles created"
  value = {
    for k, v in aws_iam_role.roles : k => {
      arn                   = v.arn
      name                  = v.name
      path                  = v.path
      unique_id             = v.unique_id
      max_session_duration  = v.max_session_duration
    }
  }
}

# Policy Outputs
output "managed_policies" {
  description = "Map of managed IAM policies created"
  value = {
    for k, v in aws_iam_policy.managed_policies : k => {
      arn         = v.arn
      name        = v.name
      path        = v.path
      policy_id   = v.policy_id
    }
  }
}

# Identity Provider Outputs
output "saml_providers" {
  description = "Map of SAML identity providers created"
  value = {
    for k, v in aws_iam_saml_provider.saml_providers : k => {
      arn = v.arn
    }
  }
}

output "oidc_providers" {
  description = "Map of OIDC identity providers created"
  value = {
    for k, v in aws_iam_openid_connect_provider.oidc_providers : k => {
      arn = v.arn
      url = v.url
    }
  }
}

# Combined outputs for easy reference
output "all_user_arns" {
  description = "List of all user ARNs"
  value       = [for user in aws_iam_user.users : user.arn]
}

output "all_role_arns" {
  description = "List of all role ARNs"
  value       = [for role in aws_iam_role.roles : role.arn]
}

output "all_policy_arns" {
  description = "List of all managed policy ARNs"
  value       = [for policy in aws_iam_policy.managed_policies : policy.arn]
}
