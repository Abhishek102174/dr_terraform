# Web server security group
module "web_security_group" {
  source = "../../"

  name        = "web-server-sg"
  description = "Security group for web servers"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access from anywhere"
    },
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access from anywhere"
    },
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/8"]
      description = "SSH access from private networks"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "security-group-example"
    Type        = "web-server"
  }
}

# Database security group
module "database_security_group" {
  source = "../../"

  name        = "database-sg"
  description = "Security group for database servers"
  vpc_id      = var.vpc_id

  ingress_rules = [
    {
      from_port                = 3306
      to_port                  = 3306
      protocol                 = "tcp"
      source_security_group_id = module.web_security_group.security_group_id
      description              = "MySQL access from web servers"
    },
    {
      from_port                = 5432
      to_port                  = 5432
      protocol                 = "tcp"
      source_security_group_id = module.web_security_group.security_group_id
      description              = "PostgreSQL access from web servers"
    }
  ]

  egress_rules = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS for updates and patches"
    }
  ]

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "security-group-example"
    Type        = "database"
  }
}