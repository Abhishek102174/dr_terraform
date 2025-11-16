output "users_table_name" {
  description = "Name of the users DynamoDB table"
  value       = module.users_table.table_name
}

output "users_table_arn" {
  description = "ARN of the users DynamoDB table"
  value       = module.users_table.table_arn
}

output "users_table_stream_arn" {
  description = "Stream ARN of the users DynamoDB table"
  value       = module.users_table.table_stream_arn
}

output "orders_table_name" {
  description = "Name of the orders DynamoDB table"
  value       = module.orders_table.table_name
}

output "orders_table_arn" {
  description = "ARN of the orders DynamoDB table"
  value       = module.orders_table.table_arn
}

output "global_secondary_indexes" {
  description = "Names of the global secondary indexes"
  value = {
    users_table  = module.users_table.global_secondary_index_names
    orders_table = module.orders_table.global_secondary_index_names
  }
}