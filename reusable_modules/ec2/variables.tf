variable "region" {
  description = "AWS region"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to launch"
  type        = number
  default     = 1
}

variable "ami_id" {
  description = "Custom AMI ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "create_key_pair" {
  description = "Create new key pair"
  type        = bool
  default     = false
}

variable "key_name" {
  description = "Existing key pair name"
  type        = string
  default     = ""
}

variable "key_pair_name" {
  description = "New key pair name"
  type        = string
  default     = "ec2-keypair"
}

variable "public_key" {
  description = "Public key for new key pair"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "VPC subnet IDs"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Security group IDs"
  type        = list(string)
}

variable "associate_public_ip" {
  description = "Associate public IP"
  type        = bool
  default     = false
}

variable "root_volume_size" {
  description = "Root volume size (GB)"
  type        = number
  default     = 8
}

variable "root_volume_type" {
  description = "Root volume type"
  type        = string
  default     = "gp3"
}

variable "root_volume_iops" {
  description = "Root volume IOPS"
  type        = number
  default     = 3000
}

variable "root_volume_throughput" {
  description = "Root volume throughput (MB/s)"
  type        = number
  default     = 125
}

variable "root_volume_encrypted" {
  description = "Encrypt root volume"
  type        = bool
  default     = true
}

variable "delete_on_termination" {
  description = "Delete root volume on termination"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "KMS ARN for volume encryption"
  type        = string
  default     = ""
}

variable "ebs_volumes" {
  description = "Additional EBS volumes"
  type = list(object({
    device_name = string
    size        = number
    type        = string
    iops        = number
    throughput  = number
    encrypted   = bool
    kms_key_id  = string
  }))
  default = []
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "enable_cpu_alarm" {
  description = "Enable CPU utilization alarm"
  type        = bool
  default     = false
}

variable "allocate_eips" {
  description = "Allocate Elastic IPs"
  type        = bool
  default     = false
}

variable "name_prefix" {
  description = "Resource name prefix"
  type        = string
}

variable "tags" {
  description = "Resource tags"
  type        = map(string)
  default     = {}
}

variable "eip_domain" {
  description = "EIP domain"
  type        = string
  default     = "vpc"
}

variable "metric_name" {
  description = "CloudWatch metric name"
  type        = string
  default     = "CPUUtilization"
}

variable "alarm_description" {
  description = "Alarm description"
  type        = string
  default     = "This metric monitors EC2 CPU utilization"
}

variable "secrets_manager_kms_key_id" {
  description = "KMS key ID for encrypting Secrets Manager secrets"
  type        = string
  default     = null
}

variable "secrets_recovery_window" {
  description = "Number of days that AWS Secrets Manager waits before deleting the secret"
  type        = number
  default     = 30
}

# IAM Configuration Variables
variable "create_iam_instance_profile" {
  description = "Whether to create an IAM instance profile"
  type        = bool
  default     = true
}

variable "iam_instance_profile_name" {
  description = "Name of existing IAM instance profile to attach to EC2 instances"
  type        = string
  default     = null
}

variable "create_secrets_manager_policy" {
  description = "Whether to create and attach Secrets Manager policy (only applicable if create_iam_instance_profile is true)"
  type        = bool
  default     = true
}

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the EC2 role"
  type        = list(string)
  default     = []
}

variable "custom_iam_policy_documents" {
  description = "List of custom IAM policy documents to attach to the EC2 role"
  type        = list(string)
  default     = []
}

variable "iam_role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "existing_private_key" {
  description = "Existing private key in PEM format to store in Secrets Manager"
  type        = string
  default     = null
  sensitive   = true
}

variable "existing_public_key" {
  description = "Existing public key in OpenSSH format (if not provided, will be derived from private key)"
  type        = string
  default     = null
}
