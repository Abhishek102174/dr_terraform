provider "aws" {
  region = "us-east-1"
}

# Create VPC and networking
module "vpc" {
  source             = "terraform-aws-modules/vpc/aws"
  version            = "~> 5.0"
  name               = "ec2-example-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["us-east-1a", "us-east-1b"]
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets    = ["10.0.3.0/24", "10.0.4.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

# Security Group
resource "aws_security_group" "web" {
  name        = "ec2-example-sg"
  description = "Allow HTTP/HTTPS and SSH"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-example-sg"
  }
}

# KMS key for Secrets Manager encryption
resource "aws_kms_key" "secrets_manager_key" {
  description             = "KMS key for EC2 key pair Secrets Manager secrets"
  deletion_window_in_days = 7
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager to use the key"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })
  
  tags = {
    Name        = "ec2-example-secrets-key"
    Environment = "dev"
    Terraform   = "true"
    Project     = "ec2-example"
  }
}

resource "aws_kms_alias" "secrets_manager_key_alias" {
  name          = "alias/ec2-example-secrets-key"
  target_key_id = aws_kms_key.secrets_manager_key.key_id
}

data "aws_caller_identity" "current" {}

# Main EC2 Module
module "ec2_cluster" {
  source          = "../../"
  region          = "us-east-1"
  instance_count  = 2
  ami_id          = "ami-0ec18f6103c5e0491"
  instance_type   = "t3.micro"
  name_prefix     = "app-server"
  create_key_pair = true
  key_pair_name   = "example-keypair-${terraform.workspace}"

  subnet_ids            = module.vpc.private_subnets
  security_group_ids    = [aws_security_group.web.id]
  root_volume_size      = 20
  root_volume_type      = "gp3"
  root_volume_encrypted = true
  delete_on_termination = true

  ebs_volumes = [
    {
      device_name = "/dev/sdf"
      size        = 10
      type        = "gp3"
      iops        = 3000
      throughput  = 125
      encrypted   = true
      kms_key_id  = null # Use default KMS key
    }
  ]

  enable_monitoring = true
  enable_cpu_alarm  = true
  allocate_eips     = false

  metric_name       = "CPUUtilization"
  alarm_description = "This metric monitors ec2 cpu utilization"

  # IAM Configuration - Use module-created role with additional policies
  create_iam_instance_profile    = true
  create_secrets_manager_policy  = true
  additional_iam_policies = [
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]
  
  # Custom policy for application-specific permissions
  custom_iam_policy_documents = [
    jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Effect = "Allow"
          Action = [
            "s3:GetObject",
            "s3:PutObject"
          ]
          Resource = "arn:aws:s3:::my-app-bucket/*"
        },
        {
          Effect = "Allow"
          Action = "s3:ListBucket"
          Resource = "arn:aws:s3:::my-app-bucket"
        }
      ]
    })
  ]

  # Secrets Manager configuration
  secrets_manager_kms_key_id = aws_kms_key.secrets_manager_key.arn
  secrets_recovery_window    = 7

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "ec2-example"
  }
}
