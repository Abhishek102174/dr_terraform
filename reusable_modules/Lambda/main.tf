# Lambda Layers
resource "aws_lambda_layer_version" "this" {
  for_each = var.lambda_layers

  filename            = each.value.filename
  s3_bucket          = each.value.s3_bucket
  s3_key             = each.value.s3_key
  layer_name         = each.value.layer_name
  description        = each.value.description
  compatible_runtimes = each.value.compatible_runtimes
  skip_destroy       = each.value.skip_destroy

  source_code_hash = each.value.filename != null ? filebase64sha256(each.value.filename) : null
}

# Layer Permissions (simplified)
resource "aws_lambda_layer_version_permission" "this" {
  for_each = var.layer_permissions

  layer_name     = each.value.layer_name
  version_number = aws_lambda_layer_version.this[each.key].version
  statement_id   = "allow-${each.key}"
  principal      = each.value.principal
  action         = each.value.action
  organization_id = each.value.organization_id

  depends_on = [aws_lambda_layer_version.this]
}

# Combine existing layers with created layers
locals {
  all_layer_arns = concat(
    var.layers,
    [for layer in aws_lambda_layer_version.this : layer.arn]
  )
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  role          = aws_iam_role.lambda.arn
  s3_bucket     = var.s3_bucket
  s3_key        = var.s3_key
  publish       = var.auto_publish || var.enable_snap_start
  
  # Conditionally include snap_start block
  dynamic "snap_start" {
    for_each = var.enable_snap_start ? [1] : []
    content {
      apply_on = "PublishedVersions"
    }
  }
  
  filename         = var.source_path != null ? var.source_path : null
  source_code_hash = var.source_path != null ? filebase64sha256(var.source_path) : null
  handler          = var.handler
  runtime          = var.runtime
  layers           = local.all_layer_arns
  environment {
    variables = var.environment_vars
  }
  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrency
  depends_on                     = [aws_cloudwatch_log_group.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_days
}

# Create new version on every invocation
resource "aws_lambda_invocation" "version_publisher" {
  count         = var.enable_snap_start ? 1 : 0
  function_name = aws_lambda_function.this.function_name
  input         = jsonencode({ "action" = "publish_version" })

  lifecycle {
    ignore_changes = [input]
    replace_triggered_by = [
      # Trigger new version on every code change
      aws_lambda_function.this.source_code_hash
    ]
  }
}

# Latest version alias
resource "aws_lambda_alias" "latest_version" {
  count            = var.enable_snap_start ? 1 : 0
  name             = "latest-version"
  function_name    = aws_lambda_function.this.function_name
  function_version = aws_lambda_function.this.version
}

resource "aws_lambda_event_source_mapping" "this" {
  for_each         = { for idx, trigger in var.triggers : idx => trigger }
  event_source_arn = each.value.event_source_arn
  function_name    = aws_lambda_function.this.arn
  batch_size       = each.value.batch_size
  enabled          = each.value.enabled
  # Only set for stream sources
  starting_position = can(regex("(kinesis|dynamodb)", each.value.event_source_arn)) ? each.value.starting_position : null
}

# S3 trigger permissions
resource "aws_lambda_permission" "s3" {
  for_each      = var.s3_triggers
  statement_id  = "AllowS3Invoke-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = each.value.bucket_arn
}
