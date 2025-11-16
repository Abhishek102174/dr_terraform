output "bucket_arns" {
  description = "ARNs of all created S3 buckets"
  value = {
    for k, bucket in aws_s3_bucket.this : k => bucket.arn
  }
}
output "bucket_domain_names" {
  description = "Domain names of all created S3 buckets"
  value = {
    for k, bucket in aws_s3_bucket.this : k => bucket.bucket_domain_name
  }
}
output "bucket_names" {
  description = "Names of all created S3 buckets"
  value = {
    for k, bucket in aws_s3_bucket.this : k => bucket.id
  }
}
output "website_endpoints" {
  description = "Website endpoints for buckets with website configuration"
  value = {
    for k, config in aws_s3_bucket_website_configuration.this : k => config.website_endpoint
  }
}
output "log_bucket_arns" {
  description = "ARNs of log buckets (if created)"
  value = {
    for k, bucket in aws_s3_bucket.log_bucket : k => bucket.arn
  }
}
output "log_bucket_names" {
  description = "Names of log buckets (if created)"
  value = {
    for k, bucket in aws_s3_bucket.log_bucket : k => bucket.id
  }
}