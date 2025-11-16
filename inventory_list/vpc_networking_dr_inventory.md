# VPC Networking DR Inventory - US-East-1

## Executive Summary
Complete networking infrastructure inventory for disaster recovery planning across 3 VPCs supporting 19 EC2 instances with complex routing via Transit Gateway and VPC peering.

## VPC Overview

### Primary Production VPC
- **VPC ID**: vpc-05328bd281599ebe3
- **CIDR**: 10.200.48.0/20
- **State**: Available
- **Tenancy**: Default
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled

### Bedrock VPC
- **VPC ID**: vpc-053ea1e138fda4494  
- **CIDR**: 10.204.0.0/19
- **State**: Available
- **Tenancy**: Default
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled

### PrismaCloud Scan VPC
- **VPC ID**: vpc-00b0f0ef826a29778
- **CIDR**: 10.0.0.0/16
- **State**: Available
- **Tenancy**: Default
- **DNS Support**: Enabled
- **DNS Hostnames**: Enabled

## Internet Gateways

### Primary VPC Gateway
- **IGW ID**: igw-04b02960a4dacc4de
- **Attached to**: vpc-05328bd281599ebe3
- **State**: Available

### Bedrock VPC Gateway  
- **IGW ID**: igw-01ef385c5c80a8866
- **Attached to**: vpc-053ea1e138fda4494
- **State**: Available

### PrismaCloud VPC Gateway
- **IGW ID**: igw-0c584eb71a3218e4e
- **Attached to**: vpc-00b0f0ef826a29778
- **State**: Available

## NAT Gateways

### Primary VPC NAT Gateway
- **NAT ID**: nat-019818dce532fa289
- **Used by**: Private subnets in primary VPC
- **Purpose**: Internet access for private instances

### Bedrock VPC NAT Gateways
- **NAT ID**: nat-0658b3d8c649b958b (AZ1)
- **NAT ID**: nat-0639c422818ef3a24 (AZ2)
- **Purpose**: Internet access for Bedrock private subnets

## Route Tables Analysis

### Primary VPC (vpc-05328bd281599ebe3) - 8 Route Tables

#### Public Route Table (rtb-0cfc656d995405bf0)
- **Purpose**: Public subnets with direct internet access
- **Associated Subnets**: 6 subnets
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → igw-04b02960a4dacc4de
  - Cross-VPC: Multiple 10.x.x.x/16 networks via Transit Gateway
  - External: 192.139.20.0/24, 192.168.139.0/24

#### Private Route Table (rtb-0427195ca0f4313b9)
- **Purpose**: Private subnets for core services
- **Associated Subnets**: 7 subnets (MongoDB, ZooKeeper, AEM, Services)
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → nat-019818dce532fa289
  - Cross-VPC: Extensive 10.x.x.x networks via Transit Gateway
  - Additional: 10.243.21.0/24, 10.243.76.0/24, 10.244.64.0/20, 10.244.96.0/20

#### Private Solr Route Table (rtb-0715ba274d7cd3e9c)
- **Purpose**: Dedicated routing for Solr cluster
- **Associated Subnets**: 3 subnets (Solr-specific)
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → nat-019818dce532fa289
  - Cross-VPC: Same extensive network access as private table

#### Private Services Route Table (rtb-0ea550a05aaea0d96)
- **Purpose**: Microservices routing
- **Associated Subnets**: 2 subnets
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → nat-019818dce532fa289
  - Cross-VPC: Additional routes including 10.243.130.0/24, 10.243.131.0/24

#### Public Services Route Table (rtb-02648bf68c0a532c2)
- **Purpose**: Public-facing services
- **Associated Subnets**: 2 subnets
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → igw-04b02960a4dacc4de
  - Cross-VPC: Same extensive network access
  - Additional: 10.62.0.0/16

#### Public SOLR Route Table (rtb-09ae23783d865a020)
- **Purpose**: Public Solr access
- **Associated Subnets**: 1 subnet
- **Key Routes**:
  - Local: 10.200.48.0/20
  - Internet: 0.0.0.0/0 → igw-04b02960a4dacc4de
  - Cross-VPC: Same network access as other public tables
  - Additional: 10.62.0.0/16

### Bedrock VPC (vpc-053ea1e138fda4494) - 5 Route Tables

#### Public Subnet Route Tables
- **rtb-003c3ec455bf3a250**: Public Subnet 1
- **rtb-09e218dafc33b686c**: Public Subnet 2
- **Key Routes**:
  - Local: 10.204.0.0/19
  - Internet: 0.0.0.0/0 → igw-01ef385c5c80a8866
  - VPC Endpoint: vpce-0f1a0efa08f3b876a

#### Private Subnet Route Tables
- **rtb-02d864ae46d5cf806**: Private Subnet 1 → nat-0658b3d8c649b958b
- **rtb-0a542abb49450a9a5**: Private Subnet 2 → nat-0639c422818ef3a24
- **Key Routes**:
  - Local: 10.204.0.0/19
  - Internet: 0.0.0.0/0 → respective NAT gateways
  - VPC Endpoint: vpce-0f1a0efa08f3b876a

### PrismaCloud VPC (vpc-00b0f0ef826a29778) - 1 Route Table

#### Default Route Table (rtb-08d42fd22c1478b7a)
- **Key Routes**:
  - Local: 10.0.0.0/16
  - Specific: 34.75.54.101/32 → igw-0c584eb71a3218e4e

## VPC Endpoints

### Primary VPC Endpoint
- **Endpoint ID**: vpce-03710268ce9ab137d
- **Used by**: All route tables in primary VPC
- **Purpose**: Private AWS service access

### Bedrock VPC Endpoint
- **Endpoint ID**: vpce-0f1a0efa08f3b876a
- **Used by**: All route tables in Bedrock VPC
- **Purpose**: Private AWS service access

## Cross-VPC Connectivity

### Transit Gateway Integration
- **TGW ID**: tgw-03cf07cee40ee201c (from EC2 inventory)
- **Connected Networks**:
  - 10.2.0.0/16
  - 10.62.0.0/16
  - 10.104.0.0/16
  - 10.105.0.0/16
  - 10.135.208.0/20
  - 10.200.0.0/20, 10.200.16.0/20, 10.200.32.0/20
  - 10.201.0.0/16
  - 10.216.0.0/16
  - 10.231.0.0/16
  - 10.243.0.0/16 (with specific /24 subnets)
  - 10.244.64.0/20, 10.244.96.0/20
  - 10.249.0.0/16

### External Network Access
- **192.139.20.0/24**: External network via IGW
- **192.168.139.0/24**: External network via IGW
- **34.75.54.101/32**: Specific external IP (PrismaCloud)

## Subnet Distribution by Service Type

### Public Subnets (Internet Gateway Access)
- **Dispatcher Services**: 3 instances across public subnets
- **Public Solr**: 1 subnet for external Solr access
- **Bedrock Public**: 2 subnets for Bedrock services

### Private Subnets (NAT Gateway Access)
- **MongoDB Cluster**: 3 subnets across AZs
- **ZooKeeper Cluster**: 3 subnets across AZs  
- **Solr Cluster**: 3 dedicated subnets
- **AEM Services**: 3 subnets across AZs
- **Microservices**: 2 subnets
- **Bedrock Private**: 2 subnets

## DR Replication Requirements

### Critical Routing Dependencies
1. **Transit Gateway**: Must replicate TGW and all route propagations
2. **NAT Gateways**: Required for private subnet internet access
3. **VPC Endpoints**: Essential for AWS service access without internet
4. **Cross-VPC Routes**: Complex routing between multiple VPC networks

### Route Table Replication Priority
1. **High Priority**: Private route tables (core services)
2. **High Priority**: Public route tables (external access)
3. **Medium Priority**: Service-specific tables (Solr, Services)
4. **Low Priority**: Unused/default tables

### Network Segmentation Preservation
- Maintain separate routing for different service tiers
- Preserve security boundaries between public/private subnets
- Replicate VPC endpoint configurations for AWS service access
- Ensure NAT gateway redundancy across availability zones

## Cost Considerations for DR
- **NAT Gateways**: $45.58/month each (3 total = ~$137/month)
- **Transit Gateway**: $36.50/month + data processing charges
- **VPC Endpoints**: Variable based on usage
- **Internet Gateways**: No hourly charges, data transfer only

## Recovery Testing Requirements
1. Verify cross-VPC connectivity via Transit Gateway
2. Test NAT gateway failover scenarios
3. Validate VPC endpoint functionality
4. Confirm external network access (192.x networks)
5. Test service-to-service communication across subnets

---
*Generated: November 11, 2025*  
*Profile: preprod*  
*Region: us-east-1*
