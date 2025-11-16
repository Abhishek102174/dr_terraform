# API Gateway v1 (REST API)
resource "aws_api_gateway_rest_api" "rest_api" {
  count                        = var.api_type == "REST" ? 1 : 0
  name                         = var.api_name
  description                  = var.api_description
  binary_media_types           = var.rest_api_binary_media_types
  minimum_compression_size     = var.rest_api_minimum_compression_size
}

# API Gateway v2 (HTTP/WebSocket)
resource "aws_apigatewayv2_api" "v2_api" {
  count         = var.api_type != "REST" ? 1 : 0
  name          = var.api_name
  protocol_type = var.api_type
  description   = var.api_description
}

# REST API Resources
resource "aws_api_gateway_resource" "rest_resources" {
  for_each = var.api_type == "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.resource_path != null
  } : {}
  
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  parent_id   = aws_api_gateway_rest_api.rest_api[0].root_resource_id
  path_part   = each.value.path_part != null ? each.value.path_part : split("/", trimprefix(each.value.resource_path, "/"))[0]
}

# REST API Methods
resource "aws_api_gateway_method" "rest_methods" {
  for_each = var.api_type == "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.resource_path != null && integration.http_method != null
  } : {}
  
  rest_api_id          = aws_api_gateway_rest_api.rest_api[0].id
  resource_id          = aws_api_gateway_resource.rest_resources[each.key].id
  http_method          = each.value.http_method
  authorization        = each.value.authorization_type
  api_key_required     = each.value.api_key_required
}

# REST API Integrations
resource "aws_api_gateway_integration" "rest_integrations" {
  for_each = var.api_type == "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.resource_path != null && integration.http_method != null
  } : {}
  
  rest_api_id             = aws_api_gateway_rest_api.rest_api[0].id
  resource_id             = aws_api_gateway_resource.rest_resources[each.key].id
  http_method             = aws_api_gateway_method.rest_methods[each.key].http_method
  integration_http_method = each.value.integration_method
  type                    = each.value.integration_type
  uri                     = each.value.integration_uri
}

# REST API Method Responses
resource "aws_api_gateway_method_response" "rest_method_responses" {
  for_each = var.api_type == "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.resource_path != null && integration.http_method != null
  } : {}
  
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  resource_id = aws_api_gateway_resource.rest_resources[each.key].id
  http_method = aws_api_gateway_method.rest_methods[each.key].http_method
  status_code = "200"
  
  response_models = {
    "application/json" = "Empty"
  }
}

# REST API Integration Responses
resource "aws_api_gateway_integration_response" "rest_integration_responses" {
  for_each = var.api_type == "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.resource_path != null && integration.http_method != null
  } : {}
  
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  resource_id = aws_api_gateway_resource.rest_resources[each.key].id
  http_method = aws_api_gateway_method.rest_methods[each.key].http_method
  status_code = aws_api_gateway_method_response.rest_method_responses[each.key].status_code
  
  depends_on = [aws_api_gateway_integration.rest_integrations]
}

# REST API Deployment (single deployment)
resource "aws_api_gateway_deployment" "rest_deployment" {
  count = var.api_type == "REST" && length(var.integrations) > 0 ? 1 : 0
  
  rest_api_id = aws_api_gateway_rest_api.rest_api[0].id
  
  depends_on = [
    aws_api_gateway_method.rest_methods,
    aws_api_gateway_integration.rest_integrations,
    aws_api_gateway_method_response.rest_method_responses,
    aws_api_gateway_integration_response.rest_integration_responses
  ]
  
  # Force redeployment when integrations change
  triggers = {
    redeployment = sha1(jsonencode([
      for integration in var.integrations : {
        path        = integration.resource_path
        method      = integration.http_method
        uri         = integration.integration_uri
        type        = integration.integration_type
      }
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# REST API Stages
resource "aws_api_gateway_stage" "rest_stages" {
  for_each = var.api_type == "REST" && length(var.integrations) > 0 ? toset(var.stages) : []
  
  deployment_id = aws_api_gateway_deployment.rest_deployment[0].id
  rest_api_id   = aws_api_gateway_rest_api.rest_api[0].id
  stage_name    = each.key
  
  dynamic "access_log_settings" {
    for_each = var.enable_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn
      format          = var.access_log_format
    }
  }
}

# V2 API Stages and deployments
resource "aws_apigatewayv2_stage" "stages" {
  for_each    = var.api_type != "REST" ? toset(var.stages) : []
  api_id      = aws_apigatewayv2_api.v2_api[0].id
  name        = each.key
  auto_deploy = var.auto_deploy
  
  dynamic "access_log_settings" {
    for_each = var.enable_logging ? [1] : []
    content {
      destination_arn = aws_cloudwatch_log_group.api_gw[0].arn
      format          = var.access_log_format
    }
  }
}

# Custom domain
resource "aws_apigatewayv2_domain_name" "custom_domain" {
  count       = var.domain_name != null ? 1 : 0
  domain_name = var.domain_name
  
  domain_name_configuration {
    certificate_arn = var.certificate_arn
    endpoint_type   = var.domain_endpoint_type
    security_policy = var.domain_security_policy
  }
}

resource "aws_apigatewayv2_api_mapping" "domain_mapping" {
  for_each    = var.domain_name != null && var.api_type != "REST" ? toset(var.stages) : []
  api_id      = aws_apigatewayv2_api.v2_api[0].id
  domain_name = aws_apigatewayv2_domain_name.custom_domain[0].id
  stage       = each.key
}

# Authorizers
resource "aws_apigatewayv2_authorizer" "lambda_auth" {
  count                             = var.authorizer_config != null && var.authorizer_config.type == "LAMBDA" && var.api_type != "REST" ? 1 : 0
  api_id                            = aws_apigatewayv2_api.v2_api[0].id
  authorizer_type                   = var.authorizer_config.lambda_authorizer_type
  name                              = var.authorizer_config.lambda_authorizer_name
  authorizer_uri                    = "arn:aws:apigateway:${data.aws_region.current.id}:lambda:path/2015-03-31/functions/${var.authorizer_config.lambda_arn}/invocations"
  identity_sources                  = var.authorizer_config.identity_sources
  authorizer_payload_format_version = var.authorizer_config.lambda_payload_format_version
}

resource "aws_apigatewayv2_authorizer" "cognito_auth" {
  count            = var.authorizer_config != null && var.authorizer_config.type == "COGNITO" && var.api_type != "REST" ? 1 : 0
  api_id           = aws_apigatewayv2_api.v2_api[0].id
  authorizer_type  = var.authorizer_config.cognito_authorizer_type
  name             = var.authorizer_config.cognito_authorizer_name
  identity_sources = var.authorizer_config.identity_sources
  
  jwt_configuration {
    audience = [var.authorizer_config.cognito_pool]
    issuer   = "https://cognito-idp.${data.aws_region.current.id}.amazonaws.com/${var.authorizer_config.cognito_pool}"
  }
}

# API key
resource "aws_api_gateway_api_key" "main" {
  count = var.enable_api_key ? 1 : 0
  name  = "${var.api_name}${var.api_key_name_suffix}"
}

# Usage plan for REST API
resource "aws_api_gateway_usage_plan" "main" {
  count = var.enable_api_key && var.api_type == "REST" ? 1 : 0
  name  = "${var.api_name}-usage-plan"
  
  dynamic "api_stages" {
    for_each = toset(var.stages)
    content {
      api_id = aws_api_gateway_rest_api.rest_api[0].id
      stage  = api_stages.value
    }
  }
  
  depends_on = [aws_api_gateway_stage.rest_stages]
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count         = var.enable_api_key && var.api_type == "REST" ? 1 : 0
  key_id        = aws_api_gateway_api_key.main[0].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.main[0].id
}

# Logging resources
resource "aws_cloudwatch_log_group" "api_gw" {
  count             = var.enable_logging ? 1 : 0
  name              = replace(var.log_group_name_format, "{api_name}", var.api_name)
  retention_in_days = var.log_retention_days
}

resource "aws_iam_role" "api_gw_logging" {
  count = var.enable_logging ? 1 : 0
  name  = "${var.api_name}${var.logging_role_name_suffix}"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "api_gw_logging" {
  count = var.enable_logging ? 1 : 0
  name  = "${var.api_name}${var.logging_policy_name_suffix}"
  role  = aws_iam_role.api_gw_logging[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Effect   = "Allow"
      Resource = "${aws_cloudwatch_log_group.api_gw[0].arn}:*"
    }]
  })
}

# Add required policy attachment
resource "aws_iam_role_policy_attachment" "api_gw_logging" {
  count      = var.enable_logging ? 1 : 0
  role       = aws_iam_role.api_gw_logging[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# API Gateway v2 Integrations
resource "aws_apigatewayv2_integration" "integrations" {
  for_each = var.api_type != "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.route_key != null
  } : {}
  
  api_id             = aws_apigatewayv2_api.v2_api[0].id
  integration_type   = each.value.integration_type
  integration_method = each.value.integration_method
  integration_uri    = each.value.integration_uri
  payload_format_version = each.value.payload_format_version
}

# API Gateway v2 Routes
resource "aws_apigatewayv2_route" "routes" {
  for_each = var.api_type != "REST" ? {
    for idx, integration in var.integrations : idx => integration
    if integration.route_key != null
  } : {}
  
  api_id    = aws_apigatewayv2_api.v2_api[0].id
  route_key = each.value.route_key
  target    = "integrations/${aws_apigatewayv2_integration.integrations[each.key].id}"
  
  # Add authorization if specified
  authorization_type = each.value.authorization_type == "CUSTOM" ? "CUSTOM" : "NONE"
  authorizer_id      = each.value.authorization_type == "CUSTOM" && var.authorizer_config != null ? (
    var.authorizer_config.type == "LAMBDA" ? try(aws_apigatewayv2_authorizer.lambda_auth[0].id, null) :
    var.authorizer_config.type == "COGNITO" ? try(aws_apigatewayv2_authorizer.cognito_auth[0].id, null) :
    null
  ) : null
}

# Data sources
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
