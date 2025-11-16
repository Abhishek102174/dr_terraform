provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "name" {
  length = 2
}

# Create required resources
resource "aws_sqs_queue" "example" {
  name = "example-queue-${random_pet.name.id}"
}

resource "aws_s3_bucket" "example" {
  bucket = "example-bucket-${random_pet.name.id}"
}

resource "aws_dynamodb_table" "example" {
  name         = "ExampleTable-${random_pet.name.id}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"
  attribute {
    name = "id"
    type = "S"
  }

  stream_enabled   = true
  stream_view_type = "NEW_IMAGE"
}

# EventBridge rule
resource "aws_cloudwatch_event_rule" "example" {
  name                = "example-rule-${random_pet.name.id}"
  schedule_expression = "rate(5 minutes)"
}

# Simple layer example
data "archive_file" "utils_layer" {
  type        = "zip"
  output_path = "${path.module}/utils-layer.zip"
  source {
    content  = <<EOF
import json
def format_response(status_code, body):
    return {
        'statusCode': status_code,
        'body': json.dumps(body)
    }
EOF
    filename = "python/utils.py"
  }
}

# Lambda function code
data "archive_file" "lambda_function" {
  type        = "zip"
  output_path = "${path.module}/lambda_function.zip"
  source {
    content = <<EOF
import json
import utils

def lambda_handler(event, context):
    return utils.format_response(200, {'message': 'Hello from Lambda with layer!'})
EOF
    filename = "lambda_function.py"
  }
}

# Lambda module with simple layer
module "lambda" {
  source         = "../../"
  function_name  = "example-lambda-${random_pet.name.id}"
  handler        = "lambda_function.lambda_handler"
  runtime        = "python3.12"
  source_path    = data.archive_file.lambda_function.output_path
  aws_region     = "us-east-1"
  timeout        = 10
  memory_size    = 256
  
  # Simple layer configuration
  lambda_layers = {
    "utils" = {
      filename            = data.archive_file.utils_layer.output_path
      layer_name         = "utils-layer-${random_pet.name.id}"
      description        = "Simple utility functions"
      compatible_runtimes = ["python3.12"]
    }
  }
  
  triggers = [
    {
      event_source_arn = aws_sqs_queue.example.arn
      batch_size       = 5
    },
    {
      event_source_arn  = aws_dynamodb_table.example.stream_arn
      starting_position = "LATEST"
    }
  ]
}

# Outputs
output "lambda_name" {
  value = module.lambda.function_name
}

output "layer_arns" {
  value = module.lambda.layer_arns
}
