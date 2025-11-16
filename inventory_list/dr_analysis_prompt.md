# DR Resource Analysis Prompt

## Task
Analyze the provided DR inventory files and create a comprehensive aggregated view of ALL resources required to make disaster recovery functional. Focus on dependencies, critical path items, and implementation priorities.

## Input Files to Analyze
1. `ec2_dr_inventory.md` - EC2 instances, dependencies, recovery order
2. `vpc_networking_dr_inventory.md` - VPC, subnets, routing, NAT gateways, IGWs
3. `security_networking_dr_inventory.md` - Security groups, NACLs, VPC peering
4. `load_balancer_dr_inventory.md` - ALBs, target groups, listeners, health checks
5. `iam_roles_dr_inventory.md` - IAM roles, policies, instance profiles

## Required Analysis Output

### 1. Critical Path Resources (Must be created first)
List resources that other components depend on, in deployment order:
- VPC and core networking
- Security groups and NACLs
- IAM roles and policies
- Key dependencies (KMS, S3 buckets, certificates)

### 2. Infrastructure Components by Priority
**High Priority (Service Critical)**
- List all resources needed for core application functionality
- Include dependencies and cross-references

**Medium Priority (Supporting Services)**
- List supporting infrastructure components
- Include monitoring, management, and operational tools

**Low Priority (Optional/Enhancement)**
- List non-critical components that can be deployed later

### 3. Cross-Account Dependencies
Identify all resources requiring coordination with other AWS accounts:
- VPC peering connections
- Cross-account IAM trust relationships
- Shared resources or services

### 4. External Dependencies
List all external systems and networks that must be configured:
- On-premises network connectivity
- Third-party integrations
- External IP whitelists
- DNS and certificate requirements

### 5. Resource Interdependencies Map
Create a dependency matrix showing:
- Which resources depend on others
- Circular dependencies to resolve
- Critical path bottlenecks


## Key Questions to Address
1. What is the minimum viable DR environment?
2. Which resources have the most complex dependencies?
3. What are the single points of failure?
5. What are the cross-region replication requirements?
6. Which resources require the most careful configuration?
