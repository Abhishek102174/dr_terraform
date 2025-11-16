bucket         = "dr-terraform-state-stage"
key            = "stage/infrastructure.tfstate"
region         = "us-east-1"
dynamodb_table = "dr-terraform-locks-stage"
encrypt        = true
