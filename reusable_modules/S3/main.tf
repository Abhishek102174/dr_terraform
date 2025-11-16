# Main S3 Buckets
resource "aws_s3_bucket" "this" {
  for_each      = var.buckets
  region        = each.value.region
  bucket        = each.value.bucket_name
  bucket_prefix = each.value.bucket_prefix
  tags          = each.value.tags
  force_destroy = each.value.force_destroy
}

# Versioning
resource "aws_s3_bucket_versioning" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if v.versioning_enabled
  }
  bucket = aws_s3_bucket.this[each.key].id
  region = each.value.region
  versioning_configuration {
    status = "Enabled"
  }
}

# Encryption 
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if v.encryption_enabled
  }
  bucket = aws_s3_bucket.this[each.key].id
  region = each.value.region
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = each.value.sse_algorithm
      kms_master_key_id = each.value.sse_algorithm == "aws:kms" ? each.value.kms_key_id : null
    }
    bucket_key_enabled = each.value.bucket_key_enabled
  }
}

# Public Access Block
resource "aws_s3_bucket_public_access_block" "this" {
  for_each                = aws_s3_bucket.this
  bucket                  = each.value.id
  region                  = each.value.region
  block_public_acls       = var.buckets[each.key].block_public_access
  block_public_policy     = var.buckets[each.key].block_public_access
  ignore_public_acls      = var.buckets[each.key].block_public_access
  restrict_public_buckets = var.buckets[each.key].block_public_access
}

# Lifecycle Rules 
resource "aws_s3_bucket_lifecycle_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if length(try(v.lifecycle_rules, {})) > 0
  }
  bucket = aws_s3_bucket.this[each.key].id
  region = each.value.region
  dynamic "rule" {
    for_each = each.value.lifecycle_rules
    content {
      id     = rule.key
      status = rule.value.enabled ? "Enabled" : "Disabled"

      # Transition rules
      dynamic "transition" {
        for_each = try(rule.value.transitions, [])
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }

      # Expiration rule
      dynamic "expiration" {
        for_each = try([rule.value.expiration_days], [])
        content {
          days = expiration.value
        }
      }

      # Filter
      filter {
        prefix = try(rule.value.filter_prefix, null)
      }
    }
  }
}

# Website Configuration 
resource "aws_s3_bucket_website_configuration" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if try(v.website != null, false)
  }
  bucket = aws_s3_bucket.this[each.key].id
  region = each.value.region
  index_document {
    suffix = each.value.website.index_document
  }
  error_document {
    key = each.value.website.error_document
  }
}

# Notifications
resource "aws_s3_bucket_notification" "this" {
  # Iterate through all created buckets
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  region   = each.value.region
  # Lambda notifications
  dynamic "lambda_function" {
    for_each = try(var.buckets[each.key].lambda_notifications, [])
    content {
      lambda_function_arn = lambda_function.value.arn
      events              = lambda_function.value.events
      filter_prefix       = try(lambda_function.value.filter_prefix, null)
      filter_suffix       = try(lambda_function.value.filter_suffix, null)
    }
  }

  # SNS notifications
  dynamic "topic" {
    for_each = try(var.buckets[each.key].sns_notifications, [])
    content {
      topic_arn     = topic.value.arn
      events        = topic.value.events
      filter_prefix = try(topic.value.filter_prefix, null)
      filter_suffix = try(topic.value.filter_suffix, null)
    }
  }

  # SQS notifications
  dynamic "queue" {
    for_each = try(var.buckets[each.key].sqs_notifications, [])
    content {
      queue_arn     = queue.value.arn
      events        = queue.value.events
      filter_prefix = try(queue.value.filter_prefix, null)
      filter_suffix = try(queue.value.filter_suffix, null)
    }
  }
  depends_on = [aws_lambda_permission.allow_s3]
}

# Lambda Permissions
resource "aws_lambda_permission" "allow_s3" {
  # Only create permissions for buckets with lambda notifications
  for_each = {
    for k, v in var.buckets : k => v
    if try(length(v.lambda_notifications) > 0, false)
  }
  statement_id  = "AllowExecutionFromS3-${each.key}"
  action        = "lambda:InvokeFunction"
  function_name = each.value.lambda_notifications[0].arn # Use first lambda ARN
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this[each.key].arn
}

# Log Buckets 
resource "aws_s3_bucket" "log_bucket" {
  for_each = {
    for k, v in var.buckets : k => v
    if try(v.logging_enabled, false)
  }
  bucket        = "${each.value.bucket_name}-log"
  region        = each.value.region
  tags          = each.value.tags
  force_destroy = each.value.force_destroy
}

# Log Bucket Policies
resource "aws_s3_bucket_policy" "log_bucket" {
  for_each = {
    for k, v in var.buckets : k => v
    if try(v.logging_enabled, false)
  }
  bucket = aws_s3_bucket.log_bucket[each.key].id
  region = each.value.region
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.log_bucket[each.key].arn}/*"
      },
      {
        Effect    = "Allow"
        Principal = { Service = "logging.s3.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.log_bucket[each.key].arn
      }
    ]
  })
}

# Bucket Logging Configuration
resource "aws_s3_bucket_logging" "this" {
  for_each = {
    for k, v in var.buckets : k => v
    if try(v.logging_enabled, false)
  }
  bucket        = aws_s3_bucket.this[each.key].id
  region        = each.value.region
  target_bucket = aws_s3_bucket.log_bucket[each.key].id
  target_prefix = each.value.logging_prefix
}

# Custom Bucket Policies 
resource "aws_s3_bucket_policy" "custom" {
  for_each = {
    for k, v in var.buckets : k => v
    if try(v.custom_policy != null, false)
  }
  bucket = aws_s3_bucket.this[each.key].id
  region = each.value.region
  policy = each.value.custom_policy
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = aws_s3_bucket.this
  bucket   = each.value.id
  region   = each.value.region

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}
