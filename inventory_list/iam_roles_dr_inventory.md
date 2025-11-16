# IAM Roles DR Inventory - Infrastructure-Used Roles

## Executive Summary
IAM roles inventory for disaster recovery planning, focusing only on roles actively used by the EC2 instances, ECS services, and other infrastructure components documented in previous DR inventories.

## Infrastructure-Used IAM Roles

### 1. AEM Role (aem_role)
**Basic Configuration**
- **Role Name**: aem_role
- **ARN**: arn:aws:iam::327711378138:role/aem_role
- **Role ID**: AROAUYTI6ZLNJRDFC7DMF
- **Created**: August 6, 2021
- **Last Used**: November 11, 2025 (Active)
- **Max Session Duration**: 3600 seconds (1 hour)

**Instance Profile**
- **Profile Name**: aem_profile
- **Profile ARN**: arn:aws:iam::327711378138:instance-profile/aem_profile
- **Used By**: AEM Author and Publish instances

**Trust Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

**Attached Policies**
1. **AmazonEC2RoleforSSM** (AWS Managed)
   - ARN: arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM
   - Purpose: Systems Manager access for patch management and remote access

2. **ssm_kms_policy** (Customer Managed)
   - ARN: arn:aws:iam::327711378138:policy/ssm_kms_policy
   - Purpose: Enhanced SSM capabilities with KMS and logging
   - **Custom Permissions**:
     - S3: PutObject to arn:aws:s3:::stage-ssm-logs/ssm-logs/*
     - KMS: Full key management operations
     - SSM Messages: Control and data channel operations
     - CloudWatch Logs: Log stream and event management

**Tags**: name: aem_role

### 2. ECS Instance Role (ecsInstanceRole)
**Basic Configuration**
- **Role Name**: ecsInstanceRole
- **ARN**: arn:aws:iam::327711378138:role/ecsInstanceRole
- **Role ID**: AROAUYTI6ZLNATXJBF2OX
- **Created**: November 18, 2020
- **Max Session Duration**: 3600 seconds (1 hour)

**Instance Profile**
- **Profile Name**: ecsInstanceRole-profile
- **Profile ARN**: arn:aws:iam::327711378138:instance-profile/ecsInstanceRole-profile
- **Used By**: ECS cluster instances (microservices)

**Trust Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

**Attached Policies**
1. **AmazonEC2ContainerServiceforEC2Role** (AWS Managed)
   - ARN: arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role
   - Purpose: ECS agent communication and container management

2. **AmazonEC2RoleforSSM** (AWS Managed)
   - ARN: arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM
   - Purpose: Systems Manager access

3. **ssm_kms_policy** (Customer Managed)
   - ARN: arn:aws:iam::327711378138:policy/ssm_kms_policy
   - Purpose: Enhanced SSM capabilities with KMS and logging

### 3. Solr ZooKeeper Role (solr_zk_role)
**Basic Configuration**
- **Role Name**: solr_zk_role
- **ARN**: arn:aws:iam::327711378138:role/solr_zk_role
- **Role ID**: AROAUYTI6ZLNCIVF4OSFN
- **Created**: June 15, 2021
- **Max Session Duration**: 3600 seconds (1 hour)

**Instance Profile**
- **Profile Name**: solr_zk_profile
- **Profile ARN**: arn:aws:iam::327711378138:instance-profile/solr_zk_profile
- **Used By**: Solr and ZooKeeper cluster instances

**Trust Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

**Attached Policies**
1. **SecretsManagerReadWrite** (AWS Managed)
   - ARN: arn:aws:iam::aws:policy/SecretsManagerReadWrite
   - Purpose: Access to secrets for database connections and API keys

2. **AmazonEC2RoleforSSM** (AWS Managed)
   - ARN: arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM
   - Purpose: Systems Manager access

3. **ssm_kms_policy** (Customer Managed)
   - ARN: arn:aws:iam::327711378138:policy/ssm_kms_policy
   - Purpose: Enhanced SSM capabilities with KMS and logging

4. **Solr-EBS-Attach-Policy** (Customer Managed)
   - ARN: arn:aws:iam::327711378138:policy/Solr-EBS-Attach-Policy
   - Purpose: EBS volume management for Solr data persistence
   - **Custom Permissions**:
     - EC2: AttachVolume, DetachVolume, DescribeVolumes, DescribeInstances, DescribeAvailabilityZones
     - Resources: arn:aws:ec2:*:*:volume/*, arn:aws:ec2:*:*:instance/*

### 4. MongoDB Role (mongodb_role)
**Basic Configuration**
- **Role Name**: mongodb_role
- **ARN**: arn:aws:iam::327711378138:role/mongodb_role
- **Role ID**: AROAUYTI6ZLNBT55ORW6A
- **Created**: June 15, 2021
- **Max Session Duration**: 3600 seconds (1 hour)

**Instance Profile**
- **Profile Name**: ssm_profile
- **Profile ARN**: arn:aws:iam::327711378138:instance-profile/ssm_profile
- **Used By**: MongoDB cluster instances

**Trust Policy**
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "ec2.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}
```

**Note**: Attached policies not retrieved in current scan - requires separate query for complete inventory.

### 5. SSM Roles (AWS Managed)
**AmazonEC2RoleforSSM**
- **Role Name**: AmazonEC2RoleforSSM
- **ARN**: arn:aws:iam::327711378138:role/AmazonEC2RoleforSSM
- **Instance Profile**: AmazonEC2RoleforSSM
- **Used By**: General EC2 instances requiring SSM access

**AmazonSSMRoleForInstancesQuickSetup**
- **Role Name**: AmazonSSMRoleForInstancesQuickSetup
- **ARN**: arn:aws:iam::327711378138:role/AmazonSSMRoleForInstancesQuickSetup
- **Instance Profile**: AmazonSSMRoleForInstancesQuickSetup
- **Used By**: Quick Setup SSM configurations

### 6. Specialized Roles

**Model Interface CLI Role**
- **Role Name**: model-interface-cli-role
- **ARN**: arn:aws:iam::327711378138:role/model-interface-cli-role
- **Instance Profile**: model-interface-cli-role
- **Created**: February 7, 2024
- **Special Trust Policy**: Allows both EC2 service and specific users/roles
- **Used By**: Bedrock/AI model interface instances

**EC2 Image Builder Role**
- **Role Name**: EC2-Image-Builder-Role-PreProd
- **ARN**: arn:aws:iam::327711378138:role/EC2-Image-Builder-Role-PreProd
- **Instance Profile**: EC2-Image-Builder-Role-PreProd
- **Created**: March 20, 2025
- **Used By**: AMI building and image management

**Tenable Security Role**
- **Role Name**: tenable_io
- **ARN**: arn:aws:iam::327711378138:role/tenable_io
- **Instance Profile**: tenable_profile
- **Created**: November 20, 2020
- **Used By**: Security scanning infrastructure

## Custom Policies for DR Replication

### 1. ssm_kms_policy
**ARN**: arn:aws:iam::327711378138:policy/ssm_kms_policy
**Attachment Count**: 5 roles
**Created**: June 15, 2021
**Description**: Enhanced SSM capabilities with KMS and logging

**Policy Document**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::stage-ssm-logs/ssm-logs/*"
    },
    {
      "Sid": "VisualEditor1",
      "Effect": "Allow",
      "Action": [
        "kms:GetPublicKey", "kms:Decrypt", "logs:DescribeLogStreams",
        "ssmmessages:OpenControlChannel", "kms:ListResourceTags",
        "kms:GetParametersForImport", "kms:DescribeCustomKeyStores",
        "s3:GetEncryptionConfiguration", "logs:CreateLogStream",
        "ssm:UpdateInstanceInformation", "kms:GetKeyRotationStatus",
        "kms:Encrypt", "ssmmessages:OpenDataChannel", "kms:DescribeKey",
        "kms:ListKeyPolicies", "logs:DescribeLogGroups",
        "kms:ListRetirableGrants", "kms:GetKeyPolicy",
        "ssmmessages:CreateControlChannel", "logs:PutLogEvents",
        "kms:ListGrants", "ssmmessages:CreateDataChannel",
        "kms:ListKeys", "kms:ListAliases", "kms:GenerateDataKey"
      ],
      "Resource": "*"
    }
  ]
}
```

### 2. Solr-EBS-Attach-Policy
**ARN**: arn:aws:iam::327711378138:policy/Solr-EBS-Attach-Policy
**Created**: September 27, 2022
**Description**: EBS volume management for Solr data persistence

**Policy Document**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:DetachVolume", "ec2:DescribeVolumes",
        "ec2:DescribeInstances", "ec2:DescribeAvailabilityZones",
        "ec2:AttachVolume"
      ],
      "Resource": [
        "arn:aws:ec2:*:*:volume/*",
        "arn:aws:ec2:*:*:instance/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": "ec2:DescribeVolumes",
      "Resource": "*"
    }
  ]
}
```

## DR Replication Requirements

### High Priority Roles (Critical Path)
1. **solr_zk_role** - Solr/ZooKeeper cluster operations
2. **mongodb_role** - Database cluster operations  
3. **ecsInstanceRole** - Microservices container management
4. **aem_role** - Content management system

### Medium Priority Roles (Supporting Services)
1. **AmazonEC2RoleforSSM** - Systems management
2. **AmazonSSMRoleForInstancesQuickSetup** - SSM automation

### Low Priority Roles (Specialized Functions)
1. **model-interface-cli-role** - AI/ML interfaces
2. **EC2-Image-Builder-Role-PreProd** - AMI management
3. **tenable_io** - Security scanning

### Dependencies for DR

**S3 Bucket Dependencies**
- **stage-ssm-logs**: Required for ssm_kms_policy
- Must be replicated or updated to DR region bucket

**KMS Key Dependencies**
- Custom KMS keys referenced in ssm_kms_policy
- Must be replicated or created in DR region

**Secrets Manager Dependencies**
- Secrets accessed by solr_zk_role via SecretsManagerReadWrite
- Database connection strings, API keys, certificates
- Must be replicated to DR region

**Cross-Account Trust Dependencies**
- model-interface-cli-role has cross-account trust relationships
- User: arn:aws:iam::327711378138:user/chemadvisor-preprod
- Role: arn:aws:iam::327711378138:role/workspace-manager-role

### Role-to-Infrastructure Mapping

**EC2 Instance Assignments** (from EC2 inventory):
- **Dispatcher Instances**: aem_role (3 instances)
- **AEM Author Instances**: aem_role (3 instances)  
- **AEM Publish Instances**: aem_role (3 instances)
- **Solr Instances**: solr_zk_role (3 instances)
- **ZooKeeper Instances**: solr_zk_role (3 instances)
- **MongoDB Instances**: mongodb_role (3 instances)
- **ECS Service Instances**: ecsInstanceRole (2 instances)
- **Bedrock Instance**: model-interface-cli-role (1 instance)

**Service-Specific Permissions**:
- **Solr Cluster**: EBS volume attachment for data persistence
- **MongoDB Cluster**: Database-specific access patterns
- **ECS Services**: Container registry and service discovery
- **AEM Services**: Content repository and workflow management

## Recovery Testing Requirements

### Role Assumption Tests
1. **EC2 Instance Profile Assignment**: Verify role attachment to instances
2. **Cross-Service Access**: Test Secrets Manager, KMS, S3 access
3. **EBS Operations**: Validate volume attach/detach for Solr instances
4. **SSM Connectivity**: Confirm Systems Manager session establishment

### Permission Validation
1. **Custom Policy Functions**: Test ssm_kms_policy and Solr-EBS-Attach-Policy
2. **AWS Managed Policies**: Verify standard SSM and ECS permissions
3. **Cross-Account Access**: Validate model-interface-cli-role trust relationships
4. **Resource Access**: Confirm S3, KMS, Secrets Manager connectivity

### Security Compliance
1. **Least Privilege**: Verify minimal required permissions
2. **Resource Restrictions**: Confirm policy resource limitations
3. **Session Duration**: Test max session duration settings
4. **Trust Relationships**: Validate assume role policies

---
*Generated: November 11, 2025*  
*Profile: preprod*  
*Region: us-east-1*  
*Infrastructure Roles: 9 Active*  
*Custom Policies: 2 Critical*
