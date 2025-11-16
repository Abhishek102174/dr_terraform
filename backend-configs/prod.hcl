bucket         = "dr-terraform-state-prod"
key            = "prod/infrastructure.tfstate"
region         = "us-east-1"
dynamodb_table = "dr-terraform-locks-prod"
encrypt        = true
