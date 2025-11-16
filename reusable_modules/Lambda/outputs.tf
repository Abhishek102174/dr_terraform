output "lambda_arn" {
  value = aws_lambda_function.this.arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "role_arn" {
  value = aws_iam_role.lambda.arn
}

output "function_name" {
  value = aws_lambda_function.this.function_name
}

# Layer outputs
output "layer_arns" {
  description = "ARNs of created Lambda layers"
  value = {
    for k, v in aws_lambda_layer_version.this : k => v.arn
  }
}

output "layer_versions" {
  description = "Version numbers of created Lambda layers"
  value = {
    for k, v in aws_lambda_layer_version.this : k => v.version
  }
}

output "all_layer_arns" {
  description = "All layer ARNs attached to the function (existing + created)"
  value = local.all_layer_arns
}
