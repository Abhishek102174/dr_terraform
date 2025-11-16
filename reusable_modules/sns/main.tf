# SNS Topic
resource "aws_sns_topic" "this" {
  name                         = var.topic_name
  display_name                = var.display_name
  fifo_topic                  = var.fifo_topic
  content_based_deduplication = var.content_based_deduplication
  kms_master_key_id           = var.kms_master_key_id
  delivery_policy             = var.delivery_policy
  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn
  http_success_feedback_role_arn           = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate        = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn           = var.http_failure_feedback_role_arn
  lambda_success_feedback_role_arn         = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate      = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn         = var.lambda_failure_feedback_role_arn
  sqs_success_feedback_role_arn            = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate         = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn            = var.sqs_failure_feedback_role_arn
  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn

  tags = var.tags
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "this" {
  for_each = var.topic_policy != null ? { policy = true } : {}

  arn    = aws_sns_topic.this.arn
  policy = var.topic_policy
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "this" {
  for_each = var.subscriptions

  topic_arn = aws_sns_topic.this.arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint

  filter_policy                    = each.value.filter_policy
  filter_policy_scope             = each.value.filter_policy_scope
  raw_message_delivery            = each.value.raw_message_delivery
  confirmation_timeout_in_minutes = each.value.confirmation_timeout_in_minutes
  endpoint_auto_confirms          = each.value.endpoint_auto_confirms
  delivery_policy                 = each.value.delivery_policy
  redrive_policy                  = each.value.redrive_policy
  replay_policy                   = each.value.replay_policy
}

# SNS Topic Data Protection Policy
resource "aws_sns_topic_data_protection_policy" "this" {
  count = var.data_protection_policy != null ? 1 : 0

  arn    = aws_sns_topic.this.arn
  policy = var.data_protection_policy
}

# SNS Platform Application
resource "aws_sns_platform_application" "this" {
  for_each = var.platform_applications

  name                = each.value.name
  platform            = each.value.platform
  platform_credential = each.value.platform_credential
  platform_principal  = try(each.value.platform_principal, null)
  
  event_delivery_failure_topic_arn = try(each.value.event_delivery_failure_topic_arn, null)
  event_endpoint_created_topic_arn = try(each.value.event_endpoint_created_topic_arn, null)
  event_endpoint_deleted_topic_arn = try(each.value.event_endpoint_deleted_topic_arn, null)
  event_endpoint_updated_topic_arn = try(each.value.event_endpoint_updated_topic_arn, null)
  
  failure_feedback_role_arn    = try(each.value.failure_feedback_role_arn, null)
  success_feedback_role_arn    = try(each.value.success_feedback_role_arn, null)
  success_feedback_sample_rate = try(each.value.success_feedback_sample_rate, null)
}