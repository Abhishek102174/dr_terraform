variable "name_prefix" {
  type        = string
  description = "Prefix for resource names"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for resources"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnet IDs for AutoScaling Group"
}

# Launch Template Configuration Variables
variable "ami_id" {
  type        = string
  description = "AMI ID for launch template"
}

variable "instance_type" {
  type        = string
  description = "Instance type for launch template"
}

variable "key_name" {
  type        = string
  description = "Key pair name for instances"
  default     = null
}

variable "user_data" {
  type        = string
  description = "User data script for instances"
  default     = null
}

variable "iam_instance_profile" {
  type        = string
  description = "IAM instance profile name"
  default     = null
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group IDs for instances"
}

variable "block_device_mappings" {
  type = list(object({
    device_name = string
    ebs = object({
      volume_size = number
      volume_type = string
      encrypted   = bool
    })
  }))
  description = "Block device mappings for instances"
  default     = []
}

# AutoScaling Group Configuration Variables
variable "min_size" {
  type        = number
  description = "Minimum number of instances in ASG"
}

variable "max_size" {
  type        = number
  description = "Maximum number of instances in ASG"
}

variable "desired_capacity" {
  type        = number
  description = "Desired number of instances in ASG"
}

variable "health_check_type" {
  type        = string
  description = "Health check type (EC2 or ELB)"
  default     = "EC2"
}

variable "health_check_grace_period" {
  type        = number
  description = "Health check grace period in seconds"
  default     = 300
}

variable "target_group_arns" {
  type        = list(string)
  description = "Target group ARNs for load balancer"
  default     = []
}

variable "termination_policies" {
  type        = list(string)
  description = "Termination policies for ASG"
  default     = ["Default"]
}

# Scaling Policy Variables
variable "enable_scale_up_policy" {
  type        = bool
  description = "Enable scale up policy"
  default     = false
}

variable "scale_up_adjustment" {
  type        = number
  description = "Number of instances to add when scaling up"
  default     = 1
}

variable "scale_up_cooldown" {
  type        = number
  description = "Cooldown period in seconds for scale up"
  default     = 300
}

variable "enable_scale_down_policy" {
  type        = bool
  description = "Enable scale down policy"
  default     = false
}

variable "scale_down_adjustment" {
  type        = number
  description = "Number of instances to remove when scaling down"
  default     = -1
}

variable "scale_down_cooldown" {
  type        = number
  description = "Cooldown period in seconds for scale down"
  default     = 300
}

variable "scaling_adjustment_type" {
  type        = string
  description = "Scaling adjustment type (ChangeInCapacity, ExactCapacity, PercentChangeInCapacity)"
  default     = "ChangeInCapacity"
}

# Notification Variables
variable "enable_notifications" {
  type        = bool
  description = "Enable ASG notifications"
  default     = false
}

variable "notification_topic_arn" {
  type        = string
  description = "SNS topic ARN for notifications"
  default     = ""
}

variable "notification_types" {
  type        = list(string)
  description = "Types of notifications to send"
  default = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]
}

variable "tags" {
  type        = map(string)
  description = "Common tags for all resources"
  default     = {}
}

variable "enable_sns_notifications" {
  description = "Enable SNS notifications for AutoScaling events"
  type        = bool
  default     = true
}
