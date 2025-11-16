provider "aws" {
  region = "us-east-1"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_exec" {
  name = "lambda-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach Lambda execution policy
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create ZIP archive for Lambda authorizer
data "archive_file" "authorizer" {
  type        = "zip"
  output_path = "${path.module}/authorizer.zip"

  source {
    content  = <<EOF
import json

def lambda_handler(event, context):
    print(f"Authorizer event: {json.dumps(event)}")
    
    # Simple authorization logic - check for valid token
    token = event.get('headers', {}).get('authorization', '')
    
    if token == 'Bearer valid-token':
        policy = {
            "principalId": "user123",
            "policyDocument": {
                "Version": "2012-10-17",
                "Statement": [
                    {
                        "Action": "execute-api:Invoke",
                        "Effect": "Allow",
                        "Resource": event['methodArn']
                    }
                ]
            },
            "context": {
                "userId": "user123",
                "userName": "testuser"
            }
        }
        return policy
    else:
        raise Exception('Unauthorized')
EOF
    filename = "authorizer.py"
  }
}

# Create Lambda authorizer
resource "aws_lambda_function" "authorizer" {
  filename         = data.archive_file.authorizer.output_path
  function_name    = "api-authorizer"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "authorizer.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.authorizer.output_base64sha256
}

# Backend Lambda function
data "archive_file" "backend" {
  type        = "zip"
  output_path = "${path.module}/backend.zip"

  source {
    content  = <<EOF
import json
import os

def lambda_handler(event, context):
    print(f"Backend event: {json.dumps(event)}")
    
    # Extract information from the event (works for both REST and HTTP APIs)
    http_method = event.get('httpMethod') or event.get('requestContext', {}).get('http', {}).get('method')
    path = event.get('path') or event.get('rawPath', '')
    stage = event.get('requestContext', {}).get('stage', 'unknown')
    api_type = "REST" if 'httpMethod' in event else "HTTP"
    
    response_body = {
        'message': f'Hello from {api_type} API Gateway Backend!',
        'method': http_method,
        'path': path,
        'stage': stage,
        'timestamp': context.aws_request_id,
        'environment': os.environ.get('ENVIRONMENT', 'development'),
        'api_type': api_type
    }
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Headers': 'Content-Type,Authorization',
            'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS'
        },
        'body': json.dumps(response_body)
    }
EOF
    filename = "backend.py"
  }
}

resource "aws_lambda_function" "backend" {
  filename         = data.archive_file.backend.output_path
  function_name    = "api-backend"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "backend.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.backend.output_base64sha256
}

# Users service Lambda function
data "archive_file" "users_service" {
  type        = "zip"
  output_path = "${path.module}/users_service.zip"

  source {
    content  = <<EOF
import json

def lambda_handler(event, context):
    print(f"Users service event: {json.dumps(event)}")
    
    http_method = event.get('httpMethod') or event.get('requestContext', {}).get('http', {}).get('method')
    path_params = event.get('pathParameters') or {}
    
    # Mock users data
    users = [
        {"id": 1, "name": "John Doe", "email": "john@example.com"},
        {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
    ]
    
    if http_method == 'GET':
        user_id = path_params.get('id')
        if user_id:
            user = next((u for u in users if u['id'] == int(user_id)), None)
            if user:
                response_body = user
            else:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'User not found'})
                }
        else:
            response_body = {'users': users}
    elif http_method == 'POST':
        response_body = {'message': 'User created successfully', 'id': 3}
    elif http_method == 'PUT':
        user_id = path_params.get('id')
        response_body = {'message': f'User {user_id} updated successfully'}
    elif http_method == 'DELETE':
        user_id = path_params.get('id')
        response_body = {'message': f'User {user_id} deleted successfully'}
    else:
        response_body = {'error': 'Method not allowed'}
    
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_body)
    }
EOF
    filename = "users_service.py"
  }
}

resource "aws_lambda_function" "users_service" {
  filename         = data.archive_file.users_service.output_path
  function_name    = "users-service"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "users_service.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.users_service.output_base64sha256
}

# Async handler Lambda function
data "archive_file" "async_handler" {
  type        = "zip"
  output_path = "${path.module}/async_handler.zip"

  source {
    content  = <<EOF
import json
import time

def lambda_handler(event, context):
    print(f"Async handler event: {json.dumps(event)}")
    
    # Simulate some async processing
    time.sleep(1)
    
    response_body = {
        'message': 'Async processing completed!',
        'processed_at': str(time.time()),
        'request_id': context.aws_request_id,
        'function_name': context.function_name
    }
    
    return {
        'statusCode': 202,
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        'body': json.dumps(response_body)
    }
EOF
    filename = "async_handler.py"
  }
}

resource "aws_lambda_function" "async_handler" {
  filename         = data.archive_file.async_handler.output_path
  function_name    = "api-async-handler"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "async_handler.lambda_handler"
  runtime          = "python3.9"
  source_code_hash = data.archive_file.async_handler.output_base64sha256
}

# Example 1: REST API Gateway
module "rest_api_gateway" {
  source          = "../../"
  api_name        = "example-rest-api"
  api_type        = "REST"
  region          = "us-east-1"
  stages          = ["dev", "staging", "prod"]
  domain_name     = null
  certificate_arn = null

  # REST APIs don't support Lambda authorizers in the same way as HTTP APIs
  # You'd need to use aws_api_gateway_authorizer separately for REST APIs
  authorizer_config = null

  enable_api_key = true
  enable_logging = true

  # REST API integrations - note the different structure
  integrations = [
    {
      resource_path      = "/health"
      http_method        = "GET"
      integration_type   = "AWS_PROXY"
      integration_method = "POST"
      integration_uri    = aws_lambda_function.backend.invoke_arn
      authorization_type = "NONE"
      api_key_required   = false
    },
    {
      resource_path      = "/users"
      http_method        = "GET"
      integration_type   = "AWS_PROXY"
      integration_method = "POST"
      integration_uri    = aws_lambda_function.users_service.invoke_arn
      authorization_type = "NONE"
      api_key_required   = false
    },
    {
      resource_path      = "/users"
      http_method        = "POST"
      integration_type   = "AWS_PROXY"
      integration_method = "POST"
      integration_uri    = aws_lambda_function.users_service.invoke_arn
      authorization_type = "NONE"
      api_key_required   = true # Require API key for POST operations
    },
    {
      resource_path      = "/async"
      http_method        = "POST"
      integration_type   = "AWS_PROXY"
      integration_method = "POST"
      integration_uri    = aws_lambda_function.async_handler.invoke_arn
      authorization_type = "NONE"
      api_key_required   = false
    }
  ]
}

# Example 2: HTTP API Gateway
module "http_api_gateway" {
  source          = "../../"
  api_name        = "example-http-api"
  api_type        = "HTTP"
  region          = "us-east-1"
  stages          = ["dev", "staging", "prod"]
  domain_name     = null
  certificate_arn = null

  authorizer_config = {
    type             = "LAMBDA"
    lambda_arn       = aws_lambda_function.authorizer.arn
    identity_sources = ["$request.header.Authorization"]
  }

  enable_api_key = true
  enable_logging = true

  # HTTP API integrations - using route_key format
  integrations = [
    {
      route_key              = "GET /"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.backend.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "GET /health"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.backend.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "GET /users"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.users_service.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "POST /users"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.users_service.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "GET /users/{id}"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.users_service.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "PUT /users/{id}"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.users_service.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "DELETE /users/{id}"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.users_service.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "POST /async"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.async_handler.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    },
    {
      route_key              = "GET /protected"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.backend.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "CUSTOM"
    },
    {
      route_key              = "OPTIONS /{proxy+}"
      integration_type       = "AWS_PROXY"
      integration_method     = "POST"
      integration_uri        = aws_lambda_function.backend.invoke_arn
      payload_format_version = "2.0"
      authorization_type     = "NONE"
    }
  ]
}

# Grant API Gateway permission to invoke Lambda functions for REST API
resource "aws_lambda_permission" "rest_api_gw_authorizer" {
  statement_id  = "AllowExecutionFromAPIGateway-REST-Authorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.rest_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "rest_api_gw_backend" {
  statement_id  = "AllowExecutionFromAPIGateway-REST-Backend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.rest_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "rest_api_gw_users" {
  statement_id  = "AllowExecutionFromAPIGateway-REST-Users"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.rest_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "rest_api_gw_async" {
  statement_id  = "AllowExecutionFromAPIGateway-REST-Async"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.async_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.rest_api_gateway.api_execution_arn
}

# Grant API Gateway permission to invoke Lambda functions for HTTP API
resource "aws_lambda_permission" "http_api_gw_authorizer" {
  statement_id  = "AllowExecutionFromAPIGateway-HTTP-Authorizer"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.http_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "http_api_gw_backend" {
  statement_id  = "AllowExecutionFromAPIGateway-HTTP-Backend"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.http_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "http_api_gw_users" {
  statement_id  = "AllowExecutionFromAPIGateway-HTTP-Users"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.users_service.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.http_api_gateway.api_execution_arn
}

resource "aws_lambda_permission" "http_api_gw_async" {
  statement_id  = "AllowExecutionFromAPIGateway-HTTP-Async"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.async_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = module.http_api_gateway.api_execution_arn
}