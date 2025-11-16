# Outputs for REST API
output "rest_api_info" {
  description = "REST API Gateway information"
  value = {
    api_id        = module.rest_api_gateway.api_id
    api_endpoint  = module.rest_api_gateway.api_endpoint
    stage_urls    = module.rest_api_gateway.stage_urls
    api_key_id    = module.rest_api_gateway.api_key_id
    usage_plan_id = module.rest_api_gateway.usage_plan_id
  }
}

output "http_api_info" {
  description = "HTTP API Gateway information"
  value = {
    api_id         = module.http_api_gateway.api_id
    api_endpoint   = module.http_api_gateway.api_endpoint
    stage_urls     = module.http_api_gateway.stage_urls
    api_key_id     = module.http_api_gateway.api_key_id
    authorizer_id  = module.http_api_gateway.authorizer_id
  }
}

output "rest_api_test_commands" {
  description = "Test commands for REST API"
  value = [
    "# Get API key first:",
    "aws apigateway get-api-key --api-key ${module.rest_api_gateway.api_key_id} --include-value",
    "",
    "# Test REST API endpoints:",
    "curl -X GET \"${module.rest_api_gateway.stage_urls["dev"]}/health\"",
    "curl -X GET \"${module.rest_api_gateway.stage_urls["dev"]}/users\"",
    "curl -X POST \"${module.rest_api_gateway.stage_urls["dev"]}/users\" -H \"x-api-key: YOUR_API_KEY\"",
    "curl -X POST \"${module.rest_api_gateway.stage_urls["dev"]}/async\""
  ]
}

output "http_api_test_commands" {
  description = "Test commands for HTTP API"
  value = [
    "# Test HTTP API endpoints:",
    "curl -X GET \"${values(module.http_api_gateway.stage_urls)[0]}/health\"",
    "curl -X GET \"${values(module.http_api_gateway.stage_urls)[0]}/users\"",
    "curl -X POST \"${values(module.http_api_gateway.stage_urls)[0]}/users\"",
    "curl -X GET \"${values(module.http_api_gateway.stage_urls)[0]}/users/1\"",
    "curl -X PUT \"${values(module.http_api_gateway.stage_urls)[0]}/users/1\"",
    "curl -X DELETE \"${values(module.http_api_gateway.stage_urls)[0]}/users/1\"",
    "curl -X POST \"${values(module.http_api_gateway.stage_urls)[0]}/async\"",
    "",
    "# Test protected endpoint (requires authorization):",
    "curl -X GET \"${values(module.http_api_gateway.stage_urls)[0]}/protected\" -H \"Authorization: Bearer valid-token\""
  ]
}

# Legacy outputs for backward compatibility (pointing to HTTP API)
output "api_url" {
  description = "API endpoint URL (HTTP API)"
  value       = module.http_api_gateway.api_endpoint
}

output "custom_domain" {
  description = "Custom domain endpoint"
  value       = module.http_api_gateway.custom_domain_endpoint
}

output "dev_stage_url" {
  description = "Development stage URL (HTTP API)"
  value       = try(module.http_api_gateway.stage_urls["dev"], null)
}

output "api_info" {
  description = "API Gateway information (HTTP API)"
  value = {
    api_id          = module.http_api_gateway.api_id
    api_endpoint    = module.http_api_gateway.api_endpoint
    api_arn         = module.http_api_gateway.api_arn
    stage_urls      = module.http_api_gateway.stage_urls
    api_key_id      = module.http_api_gateway.api_key_id
    authorizer_id   = module.http_api_gateway.authorizer_id
    integration_ids = module.http_api_gateway.integration_ids
    log_group_name  = module.http_api_gateway.log_group_name
  }
}

output "test_endpoints" {
  description = "Test endpoints for different integration methods (HTTP API)"
  value = {
    for stage_name, stage_url in module.http_api_gateway.stage_urls : stage_name => {
      public_endpoints = {
        root        = "${stage_url}/"
        hello       = "${stage_url}/health"
        users       = "${stage_url}/users"
        async       = "${stage_url}/async"
        options     = "${stage_url}/anything"
      }
      protected_endpoints = {
        protected   = "${stage_url}/protected"
        update_user = "${stage_url}/users/123"
        delete_user = "${stage_url}/users/123"
      }
    }
  }
}

output "api_key" {
  description = "API key for testing (if enabled)"
  value       = module.http_api_gateway.api_key
  sensitive   = true
}
