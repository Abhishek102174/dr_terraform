# MemoryDB Terraform Module

This module creates AWS MemoryDB for Redis clusters with comprehensive configuration options including subnet groups, parameter groups, ACLs, users, and snapshots.

## Features

- **MemoryDB Cluster** with configurable shards and replicas
- **Subnet Group** for network isolation
- **Parameter Group** for custom Redis configuration
- **Access Control Lists (ACLs)** for security
- **User Management** with authentication modes
- **Automatic Snapshots** with configurable retention
- **TLS Encryption** in transit
- **Data Tiering** support for cost optimization
- **Auto Minor Version Upgrades**
- **SNS Notifications** for cluster events
- **Comprehensive Tagging** support

## Usage

### Basic MemoryDB Cluster

```hcl
module "memorydb" {
  source = "./modules/memorydb"

  cluster_name = "my-memorydb-cluster"
  node_type    = "db.t4g.small"
  num_shards   = 2

  subnet_ids         = ["subnet-12345", "subnet-67890"]
  security_group_ids = ["sg-12345"]

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

### Advanced Configuration with Custom Parameters

```hcl
module "memorydb_advanced" {
  source = "./modules/memorydb"

  cluster_name        = "advanced-memorydb"
  cluster_description = "Advanced MemoryDB cluster with custom configuration"
  node_type          = "db.r7g.large"
  num_shards         = 3
  num_replicas_per_shard = 2

  # Network Configuration
  subnet_ids         = ["subnet-12345", "subnet-67890", "subnet-abcde"]
  security_group_ids = ["sg-12345"]

  # Custom Parameter Group
  create_parameter_group    = true
  parameter_group_name      = "custom-memorydb-params"
  parameter_group_family    = "memorydb_redis7"
  parameters = [
    {
      name  = "maxmemory-policy"
      value = "allkeys-lru"
    }
  ]

  # Custom ACL and Users
  create_acl     = true
  acl_name       = "custom-acl"
  acl_user_names = ["app-user", "admin-user"]

  users = {
    "app-user" = {
      access_string = "on ~* +@all -@dangerous"
      authentication_mode = {
        type      = "password"
        passwords = ["secure-password-123"]
      }
    }
    "admin-user" = {
      access_string = "on ~* +@all"
      authentication_mode = {
        type      = "password"
        passwords = ["admin-password-456"]
      }
    }
  }

  # Security
  tls_enabled = true

  # Backup Configuration
  snapshot_retention_limit = 7
  snapshot_window         = "03:00-05:00"

  # Notifications
  sns_topic_arn = "arn:aws:sns:us-east-1:123456789012:memorydb-notifications"

  tags = {
    Environment = "production"
    Project     = "advanced-project"
    Terraform   = "true"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cluster_name | Name of the MemoryDB cluster | `string` | n/a | yes |
| cluster_description | Description of the MemoryDB cluster | `string` | `null` | no |
| node_type | Instance class to use for the cluster nodes | `string` | `"db.t4g.small"` | no |
| num_shards | Number of shards in the cluster | `number` | `1` | no |
| num_replicas_per_shard | Number of replicas per shard | `number` | `1` | no |
| subnet_ids | List of subnet IDs for the subnet group | `list(string)` | `[]` | no |
| security_group_ids | List of security group IDs | `list(string)` | `[]` | no |
| create_parameter_group | Create a parameter group | `bool` | `false` | no |
| create_acl | Create an ACL | `bool` | `false` | no |
| users | Map of users to create | `map(object)` | `{}` | no |
| tls_enabled | Enable TLS encryption | `bool` | `true` | no |
| tags | Map of tags to assign to resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster_arn | ARN of the MemoryDB cluster |
| cluster_endpoint | DNS hostname of the cluster configuration endpoint |
| cluster_name | Name of the MemoryDB cluster |
| cluster_port | Port number on which the cluster accepts connections |
| subnet_group_name | Name of the subnet group |
| parameter_group_name | Name of the parameter group |
| acl_name | Name of the ACL |
| user_names | Map of user names |

## Integration Examples

### With VPC Module
```hcl
module "vpc" {
  source = "./modules/vpc"
  # VPC configuration
}

module "memorydb" {
  source = "./modules/memorydb"
  
  cluster_name = "my-cluster"
  subnet_ids   = module.vpc.private_subnet_ids
  
  depends_on = [module.vpc]
}
```

### With Security Group Module
```hcl
module "security_group" {
  source = "./modules/security_group"
  # Security group configuration
}

module "memorydb" {
  source = "./modules/memorydb"
  
  cluster_name       = "my-cluster"
  security_group_ids = [module.security_group.security_group_id]
}
```