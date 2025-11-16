output "instance_ids" {
  description = "EC2 instance IDs"
  value       = aws_instance.ec2_instance[*].id
}

output "instance_public_ips" {
  description = "Public IP addresses"
  value       = aws_instance.ec2_instance[*].public_ip
}

output "instance_private_ips" {
  description = "Private IP addresses"
  value       = aws_instance.ec2_instance[*].private_ip
}

output "eip_public_ips" {
  description = "Elastic IP addresses"
  value       = aws_eip.instance_eip[*].public_ip
}

output "key_pair_name" {
  description = "Key pair name"
  value       = var.create_key_pair ? aws_key_pair.instance_key_pair[0].key_name : null
}

output "private_key_secret_arn" {
  description = "Secrets Manager secret ARN containing the private key"
  value       = var.create_key_pair ? aws_secretsmanager_secret.private_key[0].arn : null
}

output "private_key_secret_name" {
  description = "Secrets Manager secret name containing the private key"
  value       = var.create_key_pair ? aws_secretsmanager_secret.private_key[0].name : null
}

output "public_key" {
  description = "Public key content"
  value       = var.create_key_pair ? tls_private_key.ec2_key_pair[0].public_key_openssh : null
}

output "iam_role_arn" {
  description = "IAM role ARN for EC2 instances (only if created by this module)"
  value       = var.create_iam_instance_profile ? aws_iam_role.ec2_role[0].arn : null
}

output "iam_role_name" {
  description = "IAM role name for EC2 instances (only if created by this module)"
  value       = var.create_iam_instance_profile ? aws_iam_role.ec2_role[0].name : null
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name used by EC2 instances"
  value       = local.instance_profile_name
}

output "iam_instance_profile_arn" {
  description = "IAM instance profile ARN (only if created by this module)"
  value       = var.create_iam_instance_profile ? aws_iam_instance_profile.ec2_profile[0].arn : null
}
