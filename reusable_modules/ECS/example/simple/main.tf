provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "notification_email" {
  description = "Email address for CloudWatch alarm notifications"
  type        = string
  default     = "admin@example.com"
}

# Create SNS topic for alarm notifications
resource "aws_sns_topic" "ecs_alerts" {
  name = "ecs-alerts"

  tags = {
    Environment = "example"
    Purpose     = "ECS monitoring alerts"
  }
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.ecs_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email
}

# Create a simple VPC for testing
resource "aws_vpc" "test" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "test-vpc"
  }
}

# Create an Internet Gateway
resource "aws_internet_gateway" "test" {
  vpc_id = aws_vpc.test.id

  tags = {
    Name = "test-igw"
  }
}

# Create public subnets
resource "aws_subnet" "public" {
  count = 2

  vpc_id                  = aws_vpc.test.id
  cidr_block              = "10.0.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "test-public-subnet-${count.index + 1}"
  }
}

# Create private subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id            = aws_vpc.test.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "test-private-subnet-${count.index + 1}"
  }
}

# Get available AZs
data "aws_availability_zones" "available" {
  state = "available"
}

# Create route table for public subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.test.id
  }

  tags = {
    Name = "test-public-rt"
  }
}

# Create NAT Gateway for private subnets
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "test-nat-eip"
  }
}

resource "aws_nat_gateway" "test" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "test-nat-gateway"
  }

  depends_on = [aws_internet_gateway.test]
}

# Create route table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.test.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.test.id
  }

  tags = {
    Name = "test-private-rt"
  }
}

# Associate route tables with subnets
resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Create security group for Fargate service
resource "aws_security_group" "ecs_fargate" {
  name_prefix = "ecs-fargate-"
  vpc_id      = aws_vpc.test.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-fargate-sg"
  }
}

# Create security group for EC2 ECS service
resource "aws_security_group" "ecs_ec2" {
  name_prefix = "ecs-ec2-"
  vpc_id      = aws_vpc.test.id

  ingress {
    from_port   = 32768
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-ec2-sg"
  }
}

# First service creates the cluster
module "ecs_EC2_simple" {
  source      = "../../"
  name        = "simple-web-app"
  region      = var.region
  launch_type = "EC2"

  # This will create a new cluster
  create_cluster = true
  cluster_name   = "shared-ecs-cluster"

  subnets          = aws_subnet.private[*].id
  security_groups  = [aws_security_group.ecs_fargate.id]
  assign_public_ip = false

  container_definitions = jsonencode([{
    name      = "simple-web"
    image     = "nginx:latest"
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])

  desired_count = 1

  enable_cloudwatch_logging = true
  enable_cloudwatch_alarms  = false
  log_retention_in_days     = 7

  tags = {
    Environment = "example"
    Type        = "simple"
  }
}

# Second service uses the existing cluster
module "ecs_ec2_daemon" {
  source      = "../../"
  name        = "monitoring-daemon"
  region      = var.region
  launch_type = "EC2"

  # Use the existing cluster created by the first service
  create_cluster       = false
  existing_cluster_arn = module.ecs_EC2_simple.cluster_arn

  security_groups = [aws_security_group.ecs_ec2.id]

  container_definitions = jsonencode([{
    name      = "monitoring-agent"
    image     = "amazon/cloudwatch-agent:latest"
    cpu       = 128
    memory    = 256
    essential = true
  }])

  desired_count = 1
  is_daemon     = true

  enable_cloudwatch_logging = true
  enable_cloudwatch_alarms  = false
  enable_health_checks      = true
  health_check_config = {
    command      = ["CMD-SHELL", "echo 'healthy'"]
    interval     = 30
    timeout      = 5
    retries      = 3
    start_period = 60
  }

  tags = {
    Environment = "example"
    Type        = "daemon"
  }

  # Ensure this service waits for the first one to create the cluster
  depends_on = [module.ecs_EC2_simple]
}

# Third service also uses the same cluster
module "ecs_custom_app" {
  source      = "../../"
  name        = "custom-microservice"
  region      = var.region
  launch_type = "EC2"

  # Use the existing cluster
  create_cluster       = false
  existing_cluster_arn = module.ecs_EC2_simple.cluster_arn

  subnets          = aws_subnet.private[*].id
  security_groups  = [aws_security_group.ecs_fargate.id]
  assign_public_ip = false

  container_definitions = jsonencode([{
    name      = "api-server"
    image     = "httpd:latest"
    cpu       = 256
    memory    = 512
    essential = true

    portMappings = [{
      containerPort = 80
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])

  desired_count = 2

  enable_cloudwatch_logging    = true
  enable_cloudwatch_alarms     = false
  alarm_notification_topic_arn = aws_sns_topic.ecs_alerts.arn

  enable_health_checks = true
  health_check_config = {
    command      = ["CMD-SHELL", "curl -f http://localhost:80/ || exit 1"]
    interval     = 30
    timeout      = 5
    retries      = 3
    start_period = 60
  }

  tags = {
    Environment = "example"
    Type        = "microservice"
  }

  depends_on = [module.ecs_EC2_simple]
}
