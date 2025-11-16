output "api_id" {
  description = "ID of the API Gateway"
  value       = var.api_type == "REST" ? try(aws_api_gateway_rest_api.rest_api[0].id, null) : try(aws_apigatewayv2_api.v2_api[0].id, null)
}

output "api_endpoint" {
  description = "Endpoint URL of the API Gateway"
  value       = var.api_type == "REST" ? try(aws_api_gateway_rest_api.rest_api[0].execution_arn, null) : try(aws_apigatewayv2_api.v2_api[0].api_endpoint, null)
}

output "api_arn" {
  description = "ARN of the API Gateway"
  value       = var.api_type == "REST" ? try(aws_api_gateway_rest_api.rest_api[0].arn, null) : try(aws_apigatewayv2_api.v2_api[0].arn, null)
}

output "custom_domain_endpoint" {
  description = "Custom domain endpoint if configured"
  value       = try(aws_apigatewayv2_domain_name.custom_domain[0].domain_name_configuration[0].target_domain_name, null)
}

output "api_key" {
  description = "API key value if enabled"
  value       = try(aws_api_gateway_api_key.main[0].value, null)
  sensitive   = true
}

output "api_key_id" {
  description = "API key ID if enabled"
  value       = try(aws_api_gateway_api_key.main[0].id, null)
}

output "stage_urls" {
  description = "Invoke URLs for each stage"
  value = var.api_type == "REST" ? {
    for stage in var.stages : stage => "https://${aws_api_gateway_rest_api.rest_api[0].id}.execute-api.${data.aws_region.current.id}.amazonaws.com/${stage}"
  } : {
    for stage in aws_apigatewayv2_stage.stages :
    stage.name => stage.invoke_url
  }
}

output "api_execution_arn" {
  description = "Execution ARN of the API Gateway"
  value = var.api_type == "REST" ? try("arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.rest_api[0].id}/*/*", null) : try("arn:aws:execute-api:${data.aws_region.current.id}:${data.aws_caller_identity.current.account_id}:${aws_apigatewayv2_api.v2_api[0].id}/*/*", null)
}

output "authorizer_id" {
  description = "ID of the authorizer if configured"
  value = var.authorizer_config != null ? (
    var.authorizer_config.type == "LAMBDA" ? try(aws_apigatewayv2_authorizer.lambda_auth[0].id, null) :
    var.authorizer_config.type == "COGNITO" ? try(aws_apigatewayv2_authorizer.cognito_auth[0].id, null) :
    null
  ) : null
}

output "log_group_name" {
  description = "CloudWatch log group name if logging is enabled"
  value       = try(aws_cloudwatch_log_group.api_gw[0].name, null)
}

output "log_group_arn" {
  description = "CloudWatch log group ARN if logging is enabled"
  value       = try(aws_cloudwatch_log_group.api_gw[0].arn, null)
}

output "logging_role_arn" {
  description = "IAM role ARN for API Gateway logging if enabled"
  value       = try(aws_iam_role.api_gw_logging[0].arn, null)
}

# Enhanced integration outputs for both API types
output "integration_ids" {
  description = "Map of integration IDs"
  value = var.api_type == "REST" ? {
    for k, v in aws_api_gateway_integration.rest_integrations : k => v.id
  } : {
    for k, v in aws_apigatewayv2_integration.integrations : k => v.id
  }
}

output "rest_api_deployment_ids" {
  description = "REST API deployment IDs by stage"
  value = var.api_type == "REST" ? {
    for k, v in aws_api_gateway_stage.rest_stages : k => aws_api_gateway_deployment.rest_deployment[0].id
  } : {}
}

output "rest_api_resource_ids" {
  description = "REST API resource IDs"
  value = {
    for k, v in aws_api_gateway_resource.rest_resources : k => v.id
  }
}

output "usage_plan_id" {
  description = "Usage plan ID if API key is enabled for REST API"
  value       = try(aws_api_gateway_usage_plan.main[0].id, null)
}

output "root_resource_id" {
  description = "Root resource ID for REST API"
  value       = var.api_type == "REST" ? try(aws_api_gateway_rest_api.rest_api[0].root_resource_id, null) : null
}
