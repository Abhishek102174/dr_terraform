output "table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.this.name
}

output "table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.this.arn
}

output "table_id" {
  description = "ID of the DynamoDB table"
  value       = aws_dynamodb_table.this.id
}

output "table_stream_arn" {
  description = "Stream ARN of the DynamoDB table"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_arn : null
}

output "table_stream_label" {
  description = "Stream label of the DynamoDB table"
  value       = var.stream_enabled ? aws_dynamodb_table.this.stream_label : null
}

output "replica_arns" {
  description = "ARNs of the DynamoDB table replicas"
  value       = var.global_table_enabled ? { for k, v in aws_dynamodb_table_replica.this : k => v.arn } : {}
}

output "global_table_enabled" {
  description = "Whether global table is enabled"
  value       = var.global_table_enabled
}

output "replica_regions" {
  description = "List of replica regions"
  value       = var.replica_regions
}

output "global_secondary_index_names" {
  description = "Names of the global secondary indexes"
  value       = [for gsi in var.global_secondary_indexes : gsi.name]
}

output "local_secondary_index_names" {
  description = "Names of the local secondary indexes"
  value       = [for lsi in var.local_secondary_indexes : lsi.name]
}