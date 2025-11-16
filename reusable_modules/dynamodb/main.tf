# Get current region
data "aws_region" "current" {}

# DynamoDB Table
resource "aws_dynamodb_table" "this" {
  name             = var.table_name
  billing_mode     = var.billing_mode
  hash_key         = var.hash_key
  range_key        = var.range_key
  read_capacity    = var.billing_mode == "PROVISIONED" ? var.read_capacity : null
  write_capacity   = var.billing_mode == "PROVISIONED" ? var.write_capacity : null
  stream_enabled   = var.stream_enabled
  stream_view_type = var.stream_enabled ? var.stream_view_type : null
  table_class      = var.table_class
  deletion_protection_enabled = var.deletion_protection_enabled

  dynamic "attribute" {
    for_each = var.attributes
    content {
      name = attribute.value.name
      type = attribute.value.type
    }
  }

  dynamic "global_secondary_index" {
    for_each = var.global_secondary_indexes
    content {
      name            = global_secondary_index.value.name
      hash_key        = global_secondary_index.value.hash_key
      range_key       = try(global_secondary_index.value.range_key, null)
      projection_type = global_secondary_index.value.projection_type
      non_key_attributes = try(global_secondary_index.value.non_key_attributes, null)
      read_capacity   = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.read_capacity, null) : null
      write_capacity  = var.billing_mode == "PROVISIONED" ? try(global_secondary_index.value.write_capacity, null) : null
    }
  }

  dynamic "local_secondary_index" {
    for_each = var.local_secondary_indexes
    content {
      name            = local_secondary_index.value.name
      range_key       = local_secondary_index.value.range_key
      projection_type = local_secondary_index.value.projection_type
      non_key_attributes = try(local_secondary_index.value.non_key_attributes, null)
    }
  }

  server_side_encryption {
    enabled = var.server_side_encryption_enabled
  }

  dynamic "point_in_time_recovery" {
    for_each = var.point_in_time_recovery_enabled ? [1] : []
    content {
      enabled = true
    }
  }

  dynamic "ttl" {
    for_each = var.ttl_enabled ? [1] : []
    content {
      attribute_name = var.ttl_attribute_name
      enabled        = true
    }
  }

  tags = var.tags
}

# Auto Scaling for Read Capacity
resource "aws_appautoscaling_target" "read_target" {
  count = var.auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.auto_scaling_read_min_capacity != null ? 1 : 0

  max_capacity       = var.auto_scaling_read_max_capacity
  min_capacity       = var.auto_scaling_read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling for Write Capacity
resource "aws_appautoscaling_target" "write_target" {
  count = var.auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.auto_scaling_write_min_capacity != null ? 1 : 0

  max_capacity       = var.auto_scaling_write_max_capacity
  min_capacity       = var.auto_scaling_write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy for Read Capacity
resource "aws_appautoscaling_policy" "read_policy" {
  count = var.auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.auto_scaling_read_min_capacity != null ? 1 : 0

  name               = "${aws_dynamodb_table.this.name}-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.read_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.read_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.read_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.auto_scaling_read_target_value
  }
}

# Auto Scaling Policy for Write Capacity
resource "aws_appautoscaling_policy" "write_policy" {
  count = var.auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.auto_scaling_write_min_capacity != null ? 1 : 0

  name               = "${aws_dynamodb_table.this.name}-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.write_target[0].resource_id
  scalable_dimension = aws_appautoscaling_target.write_target[0].scalable_dimension
  service_namespace  = aws_appautoscaling_target.write_target[0].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.auto_scaling_write_target_value
  }
}

# DynamoDB Table Replicas for Global Tables
resource "aws_dynamodb_table_replica" "this" {
  for_each = var.global_table_enabled ? toset([for region in var.replica_regions : region if region != data.aws_region.current.id]) : toset([])

  global_table_arn = aws_dynamodb_table.this.arn
  region          = each.value

  tags = var.tags
}

# Auto Scaling for GSI Read Capacity
resource "aws_appautoscaling_target" "gsi_read_target" {
  for_each = var.gsi_auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.gsi_auto_scaling_read_min_capacity != null ? toset([for gsi in var.global_secondary_indexes : gsi.name]) : toset([])

  max_capacity       = var.gsi_auto_scaling_read_max_capacity
  min_capacity       = var.gsi_auto_scaling_read_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}/index/${each.value}"
  scalable_dimension = "dynamodb:index:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling for GSI Write Capacity
resource "aws_appautoscaling_target" "gsi_write_target" {
  for_each = var.gsi_auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.gsi_auto_scaling_write_min_capacity != null ? toset([for gsi in var.global_secondary_indexes : gsi.name]) : toset([])

  max_capacity       = var.gsi_auto_scaling_write_max_capacity
  min_capacity       = var.gsi_auto_scaling_write_min_capacity
  resource_id        = "table/${aws_dynamodb_table.this.name}/index/${each.value}"
  scalable_dimension = "dynamodb:index:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}

# Auto Scaling Policy for GSI Read Capacity
resource "aws_appautoscaling_policy" "gsi_read_policy" {
  for_each = var.gsi_auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.gsi_auto_scaling_read_min_capacity != null ? toset([for gsi in var.global_secondary_indexes : gsi.name]) : toset([])

  name               = "${aws_dynamodb_table.this.name}-${each.value}-read-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_read_target[each.value].resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_read_target[each.value].scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_read_target[each.value].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }
    target_value = var.auto_scaling_read_target_value
  }
}

# Auto Scaling Policy for GSI Write Capacity
resource "aws_appautoscaling_policy" "gsi_write_policy" {
  for_each = var.gsi_auto_scaling_enabled && var.billing_mode == "PROVISIONED" && var.gsi_auto_scaling_write_min_capacity != null ? toset([for gsi in var.global_secondary_indexes : gsi.name]) : toset([])

  name               = "${aws_dynamodb_table.this.name}-${each.value}-write-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.gsi_write_target[each.value].resource_id
  scalable_dimension = aws_appautoscaling_target.gsi_write_target[each.value].scalable_dimension
  service_namespace  = aws_appautoscaling_target.gsi_write_target[each.value].service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }
    target_value = var.auto_scaling_write_target_value
  }
}