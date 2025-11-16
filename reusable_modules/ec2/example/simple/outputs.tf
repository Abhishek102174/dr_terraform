output "instance_private_ips" {
  description = "Private IP addresses of EC2 instances"
  value       = module.ec2_cluster.instance_private_ips
}

output "instance_ids" {
  description = "EC2 instance IDs"
  value       = module.ec2_cluster.instance_ids
}

output "key_pair_name" {
  description = "Name of the created key pair"
  value       = module.ec2_cluster.key_pair_name
}

output "private_key_secret_arn" {
  description = "ARN of the Secrets Manager secret containing the private key"
  value       = module.ec2_cluster.private_key_secret_arn
}

output "private_key_secret_name" {
  description = "Name of the Secrets Manager secret containing the private key"
  value       = module.ec2_cluster.private_key_secret_name
}

output "iam_role_arn" {
  description = "ARN of the IAM role attached to EC2 instances"
  value       = module.ec2_cluster.iam_role_arn
}

output "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  value       = module.ec2_cluster.iam_instance_profile_name
}

output "instance_public_ips" {
  description = "Public IP addresses of EC2 instances (if any)"
  value       = module.ec2_cluster.instance_public_ips
}

output "vpc_id" {
  description = "VPC ID where instances are deployed"
  value       = module.vpc.vpc_id
}

output "security_group_id" {
  description = "Security Group ID used by instances"
  value       = aws_security_group.web.id
}
