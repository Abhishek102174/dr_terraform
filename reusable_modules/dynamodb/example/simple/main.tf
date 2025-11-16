# Simple DynamoDB table with basic configuration
module "users_table" {
  source = "../../"

  table_name   = "users-table-example"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "user_id"
  range_key    = "created_at"
  
  attributes = [
    {
      name = "user_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    },
    {
      name = "email"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name            = "email-index"
      hash_key        = "email"
      projection_type = "ALL"
    }
  ]
  
  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  stream_enabled                 = true
  stream_view_type              = "NEW_AND_OLD_IMAGES"
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "dynamodb-example"
  }
}

# Provisioned capacity table with auto-scaling
module "orders_table" {
  source = "../../"

  table_name     = "orders-table-example"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "order_id"
  range_key      = "customer_id"
  
  attributes = [
    {
      name = "order_id"
      type = "S"
    },
    {
      name = "customer_id"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    }
  ]
  
  global_secondary_indexes = [
    {
      name            = "status-index"
      hash_key        = "status"
      range_key       = "customer_id"
      projection_type = "KEYS_ONLY"
      read_capacity   = 2
      write_capacity  = 2
    }
  ]
  
  # Enable auto-scaling
  auto_scaling_enabled              = true
  auto_scaling_read_min_capacity    = 2
  auto_scaling_read_max_capacity    = 20
  auto_scaling_read_target_value    = 70.0
  auto_scaling_write_min_capacity   = 2
  auto_scaling_write_max_capacity   = 20
  auto_scaling_write_target_value   = 70.0
  
  # GSI auto-scaling
  gsi_auto_scaling_enabled           = true
  gsi_auto_scaling_read_min_capacity = 1
  gsi_auto_scaling_read_max_capacity = 10
  gsi_auto_scaling_write_min_capacity = 1
  gsi_auto_scaling_write_max_capacity = 10
  
  server_side_encryption_enabled = true
  point_in_time_recovery_enabled = true
  ttl_enabled                    = true
  ttl_attribute_name             = "expires_at"
  
  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "dynamodb-example"
  }
}