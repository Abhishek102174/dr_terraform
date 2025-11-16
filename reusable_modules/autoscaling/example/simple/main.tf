provider "aws" {
  region = "us-east-1"
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "autoscaling-example-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "autoscaling-example-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 1}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "autoscaling-example-public-${count.index + 1}"
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "autoscaling-example-private-${count.index + 1}"
  }
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"

  tags = {
    Name = "autoscaling-example-nat-eip-${count.index + 1}"
  }
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "autoscaling-example-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "autoscaling-example-public-rt"
  }
}

# Private Route Tables
resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "autoscaling-example-private-rt-${count.index + 1}"
  }
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = 2
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# Security Groups
resource "aws_security_group" "default" {
  name_prefix = "autoscaling-example-default"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "autoscaling-example-default-sg"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "autoscaling-example-web"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
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
    Name = "autoscaling-example-web-sg"
  }
}

# Load Balancer
resource "aws_lb" "main" {
  name               = "autoscaling-example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web.id]
  subnets            = aws_subnet.public[*].id

  tags = {
    Name = "autoscaling-example-alb"
  }
}

# Target Group
resource "aws_lb_target_group" "main" {
  name     = "autoscaling-example-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    path                = "/"
    matcher             = "200"
  }

  tags = {
    Name = "autoscaling-example-tg"
  }
}

# Load Balancer Listener
resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# SNS Topic for notifications (conditional)
resource "aws_sns_topic" "autoscaling_notifications" {
  count = var.enable_sns_notifications ? 1 : 0
  name  = "autoscaling-example-notifications"

  tags = {
    Name = "autoscaling-example-sns"
  }
}

# AutoScaling Module - Updated to use individual variables
module "autoscaling" {
  source = "../.."

  # Basic Configuration
  name_prefix = "autoscaling-example"
  vpc_id      = aws_vpc.main.id
  subnet_ids  = aws_subnet.private[*].id

  # Launch Template Configuration (individual variables)
  ami_id             = data.aws_ami.amazon_linux.id
  instance_type      = "t3.micro"
  security_group_ids = [aws_security_group.default.id, aws_security_group.web.id]
  user_data          = <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd
    systemctl start httpd
    systemctl enable httpd
    echo "<h1>Hello from AutoScaling Instance!</h1>" > /var/www/html/index.html
  EOF

  # AutoScaling Group Configuration (individual variables)
  min_size                  = 1
  max_size                  = 5
  desired_capacity          = 2
  health_check_type         = "ELB"
  health_check_grace_period = 300
  termination_policies      = ["OldestInstance"]
  target_group_arns         = [aws_lb_target_group.main.arn]

  # Scaling Policies (individual variables)
  enable_scale_up_policy  = true
  scale_up_adjustment     = 1
  scale_up_cooldown       = 300
  scaling_adjustment_type = "ChangeInCapacity"

  enable_scale_down_policy = true
  scale_down_adjustment    = -1
  scale_down_cooldown      = 300

  # Notifications (individual variables)
  enable_notifications   = var.enable_sns_notifications
  notification_topic_arn = var.enable_sns_notifications ? aws_sns_topic.autoscaling_notifications[0].arn : ""
  notification_types = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE"
  ]

  # Tags
  tags = {
    Environment = "example"
    Project     = "autoscaling-demo"
  }
}
