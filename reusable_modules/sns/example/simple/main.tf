# Standard SNS Topic with comprehensive features
module "notification_topic" {
  source = "../../"

  topic_name   = var.topic_name
  display_name = var.display_name
  fifo_topic   = var.fifo_topic

  # Delivery status logging
  lambda_success_feedback_role_arn    = var.lambda_success_feedback_role_arn
  lambda_success_feedback_sample_rate = var.lambda_success_feedback_sample_rate
  lambda_failure_feedback_role_arn    = var.lambda_failure_feedback_role_arn
  
  http_success_feedback_role_arn      = var.http_success_feedback_role_arn
  http_success_feedback_sample_rate   = var.http_success_feedback_sample_rate
  http_failure_feedback_role_arn      = var.http_failure_feedback_role_arn
  
  sqs_success_feedback_role_arn       = var.sqs_success_feedback_role_arn
  sqs_success_feedback_sample_rate    = var.sqs_success_feedback_sample_rate
  sqs_failure_feedback_role_arn       = var.sqs_failure_feedback_role_arn

  application_success_feedback_role_arn    = var.application_success_feedback_role_arn
  application_success_feedback_sample_rate = var.application_success_feedback_sample_rate
  application_failure_feedback_role_arn    = var.application_failure_feedback_role_arn

  firehose_success_feedback_role_arn       = var.firehose_success_feedback_role_arn
  firehose_success_feedback_sample_rate    = var.firehose_success_feedback_sample_rate
  firehose_failure_feedback_role_arn       = var.firehose_failure_feedback_role_arn

  # Policies
  delivery_policy         = var.delivery_policy
  data_protection_policy  = var.data_protection_policy
  topic_policy           = var.topic_policy
  kms_master_key_id      = var.kms_master_key_id

  subscriptions = {
    email_admin = {
      protocol = "email"
      endpoint = var.admin_email
      filter_policy = jsonencode({
        event_type = ["error", "warning"]
      })
      raw_message_delivery = var.email_raw_delivery
    }
    webhook = {
      protocol = "https"
      endpoint = var.webhook_endpoint
      confirmation_timeout_in_minutes = var.webhook_timeout
      raw_message_delivery = var.webhook_raw_delivery
      delivery_policy = var.webhook_delivery_policy
    }
    lambda_processor = {
      protocol = "lambda"
      endpoint = var.lambda_function_arn
      filter_policy = jsonencode({
        priority = ["high", "critical"]
      })
      redrive_policy = var.lambda_redrive_policy
      replay_policy = var.lambda_replay_policy
    }
    sqs_queue = {
      protocol = "sqs"
      endpoint = var.sqs_queue_arn
      raw_message_delivery = var.sqs_raw_delivery
      filter_policy_scope = var.sqs_filter_scope
      redrive_policy = var.sqs_redrive_policy
    }
    sms_alert = {
      protocol = "sms"
      endpoint = var.sms_phone_number
      delivery_policy = var.sms_delivery_policy
    }
  }

  platform_applications = {
    ios_app = {
      name                = var.ios_app_name
      platform            = "APNS"
      platform_credential = var.apns_certificate
      platform_principal  = var.apns_principal
      event_delivery_failure_topic_arn = var.ios_failure_topic_arn
      event_endpoint_created_topic_arn = var.ios_created_topic_arn
      event_endpoint_deleted_topic_arn = var.ios_deleted_topic_arn
      event_endpoint_updated_topic_arn = var.ios_updated_topic_arn
      success_feedback_role_arn        = var.ios_success_role_arn
      failure_feedback_role_arn        = var.ios_failure_role_arn
      success_feedback_sample_rate     = var.ios_sample_rate
    }
    android_app = {
      name                = var.android_app_name
      platform            = "GCM"
      platform_credential = var.fcm_server_key
      success_feedback_role_arn = var.android_success_role_arn
      failure_feedback_role_arn = var.android_failure_role_arn
      success_feedback_sample_rate = var.android_sample_rate
    }
  }

  tags = var.tags
}

# FIFO SNS Topic
module "fifo_topic" {
  source = "../../"

  topic_name                  = var.fifo_topic_name
  display_name               = var.fifo_display_name
  fifo_topic                 = true
  content_based_deduplication = var.fifo_content_deduplication
  kms_master_key_id          = var.fifo_kms_key_id

  subscriptions = {
    fifo_sqs = {
      protocol = "sqs"
      endpoint = var.fifo_sqs_arn
      raw_message_delivery = var.fifo_sqs_raw_delivery
    }
  }

  tags = var.fifo_tags
}

# Encrypted Topic
module "encrypted_topic" {
  source = "../../"

  topic_name        = var.encrypted_topic_name
  kms_master_key_id = var.encrypted_kms_key_id
  topic_policy      = var.encrypted_topic_policy

  tags = var.encrypted_tags
}