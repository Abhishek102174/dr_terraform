data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "lambda" {
  name               = "${var.function_name}-exec-role"
  assume_role_policy = data.aws_iam_policy_document.lambda.json
}
# Basic execution role for CloudWatch logs
resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
# Attach custom policy ARNs
resource "aws_iam_role_policy_attachment" "custom" {
  for_each   = toset(var.policy_arns)
  role       = aws_iam_role.lambda.name
  policy_arn = each.value
}
# Single inline policy with dynamic permissions
data "aws_iam_policy_document" "inline" {
  # DynamoDB stream permissions
  dynamic "statement" {
    for_each = [for t in var.triggers : t if can(regex("dynamodb", t.event_source_arn))]
    content {
      actions = [
        "dynamodb:GetRecords",
        "dynamodb:GetShardIterator",
        "dynamodb:DescribeStream",
        "dynamodb:ListStreams"
      ]
      resources = [statement.value.event_source_arn]
    }
  }
  # SQS permissions
  dynamic "statement" {
    for_each = [for t in var.triggers : t if can(regex("sqs", t.event_source_arn))]
    content {
      actions = [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ]
      resources = [statement.value.event_source_arn]
    }
  }
  # S3 permissions for triggers
  dynamic "statement" {
    for_each = var.s3_triggers
    content {
      actions = [
        "s3:GetObject",
        "s3:ListBucket"
      ]
      resources = [
        statement.value.bucket_arn,
        "${statement.value.bucket_arn}/*"
      ]
    }
  }
}
# resource "aws_iam_role_policy" "inline" {
#   name   = "lambda-inline-policy"
#   role   = aws_iam_role.lambda.id
#   policy = data.aws_iam_policy_document.inline.json
# }

resource "aws_iam_role_policy" "inline" {
  count  = var.inline_policy_json != null ? 1 : 0
  name   = "${var.function_name}-inline-policy"
  role   = aws_iam_role.lambda.id
  policy = var.inline_policy_json
}

