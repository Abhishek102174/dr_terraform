# Generate private key (only if creating new key and no existing private key provided)
resource "tls_private_key" "ec2_key_pair" {
  count     = var.create_key_pair && var.existing_private_key == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Store private key in AWS Secrets Manager (for both generated and existing keys)
resource "aws_secretsmanager_secret" "private_key" {
  count                   = var.create_key_pair ? 1 : 0
  name                    = "/ec2/keypairs/${var.key_pair_name}/private-key"
  description             = "Private key for EC2 key pair ${var.key_pair_name}"
  kms_key_id              = var.secrets_manager_kms_key_id
  recovery_window_in_days = var.secrets_recovery_window
  
  tags = merge(var.tags, {
    Name        = "${var.key_pair_name}-private-key"
    KeyPairName = var.key_pair_name
  })
}

resource "aws_secretsmanager_secret_version" "private_key" {
  count         = var.create_key_pair ? 1 : 0
  secret_id     = aws_secretsmanager_secret.private_key[0].id
  # Use existing private key if provided, otherwise use generated one
  secret_string = var.existing_private_key != null ? var.existing_private_key : tls_private_key.ec2_key_pair[0].private_key_pem
}

# Create key pair
resource "aws_key_pair" "instance_key_pair" {
  count      = var.create_key_pair ? 1 : 0
  key_name   = var.key_pair_name
  # Use existing public key if provided, otherwise derive from existing private key or use generated public key
  public_key = var.existing_public_key != null ? var.existing_public_key : (
    var.existing_private_key != null ? 
    data.tls_public_key.existing_private_key[0].public_key_openssh : 
    tls_private_key.ec2_key_pair[0].public_key_openssh
  )
  tags = var.tags
}

# Extract public key from existing private key if provided
data "tls_public_key" "existing_private_key" {
  count           = var.create_key_pair && var.existing_private_key != null ? 1 : 0
  private_key_pem = var.existing_private_key
}

# IAM role for EC2 instances (only created if create_iam_instance_profile is true)
resource "aws_iam_role" "ec2_role" {
  count                = var.create_iam_instance_profile ? 1 : 0
  name                 = "${var.name_prefix}-ec2-role"
  path                 = var.iam_role_path
  permissions_boundary = var.iam_role_permissions_boundary

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Secrets Manager policy (only created if both create_iam_instance_profile and create_secrets_manager_policy are true)
resource "aws_iam_role_policy" "secrets_manager_policy" {
  count = var.create_iam_instance_profile && var.create_secrets_manager_policy ? 1 : 0
  name  = "${var.name_prefix}-secrets-manager-policy"
  role  = aws_iam_role.ec2_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = var.create_key_pair ? [aws_secretsmanager_secret.private_key[0].arn] : []
      }
    ], var.secrets_manager_kms_key_id != null ? [{
      Effect = "Allow"
      Action = [
        "kms:Decrypt"
      ]
      Resource = [var.secrets_manager_kms_key_id]
      Condition = {
        StringEquals = {
          "kms:ViaService" = "secretsmanager.${var.region}.amazonaws.com"
        }
      }
    }] : [])
  })
}

# Attach additional managed policies to the role
resource "aws_iam_role_policy_attachment" "additional_policies" {
  count      = var.create_iam_instance_profile ? length(var.additional_iam_policies) : 0
  policy_arn = var.additional_iam_policies[count.index]
  role       = aws_iam_role.ec2_role[0].name
}

# Create custom inline policies from policy documents
resource "aws_iam_role_policy" "custom_policies" {
  count  = var.create_iam_instance_profile ? length(var.custom_iam_policy_documents) : 0
  name   = "${var.name_prefix}-custom-policy-${count.index + 1}"
  role   = aws_iam_role.ec2_role[0].id
  policy = var.custom_iam_policy_documents[count.index]
}

# Instance profile for EC2 instances (only created if create_iam_instance_profile is true)
resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_instance_profile ? 1 : 0
  name  = "${var.name_prefix}-ec2-profile"
  path  = var.iam_role_path
  role  = aws_iam_role.ec2_role[0].name
  tags  = var.tags
}

# Determine which instance profile to use
locals {
  instance_profile_name = var.create_iam_instance_profile ? aws_iam_instance_profile.ec2_profile[0].name : var.iam_instance_profile_name
}

# EC2 instances
resource "aws_instance" "ec2_instance" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.create_key_pair ? aws_key_pair.instance_key_pair[0].key_name : var.key_name
  subnet_id                   = element(var.subnet_ids, count.index)
  monitoring                  = var.enable_monitoring
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = var.associate_public_ip
  iam_instance_profile        = local.instance_profile_name

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = var.root_volume_type
    iops                  = var.root_volume_iops
    throughput            = var.root_volume_throughput
    encrypted             = var.root_volume_encrypted
    delete_on_termination = var.delete_on_termination
    kms_key_id            = var.kms_key_arn
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_volumes
    content {
      device_name = ebs_block_device.value["device_name"]
      volume_size = ebs_block_device.value["size"]
      volume_type = ebs_block_device.value["type"]
      iops        = lookup(ebs_block_device.value, "iops", null)
      throughput  = lookup(ebs_block_device.value, "throughput", null)
      encrypted   = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id  = lookup(ebs_block_device.value, "kms_key_id", null)
    }
  }

  tags = merge(
    var.tags,
    {
      Name = format("%s-%02d", var.name_prefix, count.index + 1)
    }
  )
}

# Elastic IPs
resource "aws_eip" "instance_eip" {
  count    = var.allocate_eips ? var.instance_count : 0
  domain   = var.eip_domain
  instance = aws_instance.ec2_instance[count.index].id
  tags     = merge(var.tags, { Name = "${var.name_prefix}-eip-${count.index + 1}" })
}

# CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "instance_cpu_alarm" {
  count               = var.enable_cpu_alarm ? var.instance_count : 0
  alarm_name          = "${var.name_prefix}-cpu-alarm-${count.index + 1}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = var.metric_name
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 80
  alarm_description   = var.alarm_description
  dimensions = {
    InstanceId = aws_instance.ec2_instance[count.index].id
  }
  tags = var.tags
}
