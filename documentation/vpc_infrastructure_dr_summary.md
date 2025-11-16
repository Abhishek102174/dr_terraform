# VPC Infrastructure Summary for DR Replication - vpc-preprod (vpc-05328bd281599ebe3)

## VPC Overview
| Component | Details |
|-----------|---------|
| **VPC ID** | vpc-05328bd281599ebe3 |
| **VPC Name** | vpc-preprod |
| **CIDR Block** | 10.200.48.0/20 |
| **Environment** | pre-prod |
| **Region** | us-east-1 |
| **Owner ID** | 327711378138 |

## EC2 Instances Summary
| Instance ID | Instance Name | Subnet Name | Security Group Name | AZ | State |
|-------------|---------------|-------------|---------------------|----|----|
| i-07b03972248bc5cc3 | dispatcher-author | pub-subnet-5 | dispatcher-sg | us-east-1a | running |
| i-0c2b1ba435b259a3f | zk | private-subnet-solr-1 | solr-zk-sg | us-east-1a | running |
| i-02d38ea6976dc1516 | mongodb | private-subnet-mongodb-1 | mongodb-sg | us-east-1a | running |
| i-00385cfd33f9d360b | zk | private-subnet-solr-2 | solr-zk-sg | us-east-1b | running |
| i-07190d40c5e22269c | mongodb | private-subnet-mongodb-2 | mongodb-sg | us-east-1b | running |
| i-06e98bc20a1ae8229 | zk | private-subnet-solr-3 | solr-zk-sg | us-east-1c | running |
| i-047141fb7a8c0f7b6 | mongodb | private-subnet-mongodb-3 | mongodb-sg | us-east-1c | running |
| i-0f881ff9db3b73b0a | author | private-subnet-3 | author_sg | us-east-1a | running |
| i-0b267d9b2c1803127 | chemadvisor-bedrock-preprod | private-subnet-mongodb-1 | mongodb-sg | us-east-1a | stopped |
| i-02ecc7b5d54cf8a4d | services | private-subnet-service-2 | services-app-sg | us-east-1b | running |
| i-0e8c27b42097bf437 | publish | private-subnet-2 | publish-sg | us-east-1b | running |
| i-04be2f4a32a3ccf7a | services | private-subnet-service-1 | services-app-sg | us-east-1a | running |
| i-06706dad5f8f38ea2 | dispatcher | pub-subnet-4 | dispatcher-sg | us-east-1b | running |
| i-0f5dd47006865223d | solr | private-subnet-solr-2 | solr-zk-sg | us-east-1b | running |
| i-08eb676fda7eecdaf | publish | private-subnet-1 | publish-sg | us-east-1a | running |
| i-0632992ca2d1a4a80 | dispatcher | pub-subnet-3 | dispatcher-sg | us-east-1a | running |
| i-0e389d097990d4baf | solr | private-subnet-solr-1 | solr-zk-sg | us-east-1a | running |
| i-0a8beaa6592ddd148 | solr | private-subnet-solr-3 | solr-zk-sg | us-east-1c | running |

## Subnets Summary (24 Total)
| Subnet ID | Name | CIDR | AZ | Type | Available IPs | Route Table |
|-----------|------|------|----|----|---------------|-------------|
| subnet-0851ebcd3bb17e7be | private-subnet-service-1 | 10.200.56.0/25 | us-east-1a | Private | 122 | rtb-0ea550a05aaea0d96 |
| subnet-016e889b35a2f53a1 | private-subnet-service-2 | 10.200.56.128/25 | us-east-1b | Private | 122 | rtb-0ea550a05aaea0d96 |
| subnet-0f5840096e9ce7b33 | private-subnet-2 | 10.200.51.128/25 | us-east-1b | Private | 121 | rtb-0427195ca0f4313b9 |
| subnet-0ed904e4b8afc8475 | private-subnet-3 | 10.200.52.0/25 | us-east-1a | Private | 119 | rtb-0427195ca0f4313b9 |
| subnet-08a2cccea280e8f85 | private-subnet-solr-3 | 10.200.59.0/25 | us-east-1c | Private | 116 | rtb-0715ba274d7cd3e9c |
| subnet-09dae03c2e57070f4 | utilities-subnet | 10.200.61.0/27 | us-east-1a | Private | 27 | rtb-0427195ca0f4313b9 |
| subnet-03f8969696f88601a | pub-subnet-2 | 10.200.48.128/25 | us-east-1b | Public | 120 | rtb-0cfc656d995405bf0 |
| subnet-0188200b54d768632 | pub-subnet-services-2 | 10.200.55.128/25 | us-east-1b | Public | 121 | rtb-02648bf68c0a532c2 |
| subnet-074b84d6d9d9582b0 | pub-subnet-6 | 10.200.50.128/25 | us-east-1b | Public | 123 | rtb-0cfc656d995405bf0 |
| subnet-0033079c8d034f06b | private-subnet-solr-2 | 10.200.58.128/25 | us-east-1b | Private | 117 | rtb-0715ba274d7cd3e9c |
| subnet-06d7d17c5e6be647c | private-subnet-1 | 10.200.51.0/25 | us-east-1a | Private | 119 | rtb-0427195ca0f4313b9 |
| subnet-082cabe0832e7f826 | pub-subnet-services-1 | 10.200.55.0/25 | us-east-1a | Public | 122 | rtb-02648bf68c0a532c2 |
| subnet-022849cb3176e54f8 | pub-subnet-5 | 10.200.50.0/25 | us-east-1a | Public | 122 | rtb-0cfc656d995405bf0 |
| subnet-02e1e9a902ec1d2de | public-subnet-solr-1 | 10.200.59.128/28 | us-east-1c | Public | 10 | rtb-09ae23783d865a020 |
| subnet-06196bd305caf4c5f | private-subnet-solr-1 | 10.200.58.0/25 | us-east-1a | Private | 118 | rtb-0715ba274d7cd3e9c |
| subnet-0ee11af069b22e4ea | private-subnet-mongodb-1 | 10.200.53.0/27 | us-east-1a | Private | 25 | rtb-0427195ca0f4313b9 |
| subnet-03d3acf7999f8f633 | pub-subnet-4 | 10.200.49.128/25 | us-east-1b | Public | 121 | rtb-0cfc656d995405bf0 |
| subnet-0d067d4bc3e0fab23 | private-subnet-mongodb-2 | 10.200.53.32/27 | us-east-1b | Private | 26 | rtb-0427195ca0f4313b9 |
| subnet-0b6d14dd3ab2bf70f | private-subnet-mongodb-3 | 10.200.53.64/27 | us-east-1c | Private | 26 | rtb-0427195ca0f4313b9 |
| subnet-0c8d9f5161d769f89 | pub-subnet-3 | 10.200.49.0/25 | us-east-1a | Public | 120 | rtb-0cfc656d995405bf0 |
| subnet-0dea76d02d90ce122 | pub-subnet-1 | 10.200.48.0/25 | us-east-1a | Public | 119 | rtb-0cfc656d995405bf0 |

## Security Groups Summary (18 Total)
| Security Group ID | Name | Description | Key Rules |
|-------------------|------|-------------|-----------|
| sg-00f15d16aad77b85a | third-party-sg | Managed by Terraform | SSH from 192.150.10.0/24 |
| sg-0c886f9d04a25bd88 | chemadvisor | chemadvisor | No inbound rules |
| sg-0d6f14427cf61ca35 | solr-zk-sg | Managed by Terraform | SSH, Solr (8983), ZK (2181), EFS (2049) |
| sg-04ca57f9bac9c1bb1 | services-app-sg | Managed by Terraform | SSH, Oracle (1521), All ports from ELB |
| sg-08f97c3866fc6c08f | services-elb-sg | Managed by Terraform | HTTP/HTTPS from CDN ranges |
| sg-0e4432b1aee0a5394 | tenable-sg | Managed by Terraform | No inbound rules |
| sg-03b8920d66cd7535e | searchadmin-nlb-sg | Managed by Terraform | HTTP/HTTPS from 10.0.0.0/8 |
| sg-0ab6feb35e6b6789e | elb-internal-sg | Managed by Terraform | HTTP/HTTPS from VPN networks |
| sg-0e82f1b6a652cb76b | dispatcher-sg | Managed by Terraform | HTTP/HTTPS, SSH, Monit (2812) |
| sg-015514d130cb590b6 | default | default VPC security group | All traffic within SG |
| sg-081585538c4d1cb66 | elb-sg | Managed by Terraform | HTTP/HTTPS from CDN/global ranges |
| sg-08c2f6a34480cf272 | publish-sg | Managed by Terraform | SSH, AEM ports (4503, 4505), JMX (9999, 8686) |
| sg-0ab78fd99a0aa09d3 | ssm_sg | Managed by Terraform | HTTPS for SSM |
| sg-01a97b4eaf45171d7 | sftp_access_sg | Managed by Terraform | SSH, NFS (2049) |
| sg-0a4c6e59268dc6397 | mongodb-sg | Managed by Terraform | SSH, MongoDB (27017) |
| sg-0f35db329ea74062c | author_sg | Managed by Terraform | SSH, AEM (4502), JMX (9999, 8686) |

## Internet Gateway
| IGW ID | Name | State | Attachment |
|--------|------|-------|------------|
| igw-04b02960a4dacc4de | igw-preprod | available | vpc-05328bd281599ebe3 |

## NAT Gateway
| NAT ID | Name | State | Subnet Name | Public IP | Private IP |
|--------|------|-------|-------------|-----------|------------|
| nat-019818dce532fa289 | preprod NAT | available | pub-subnet-1 | 34.203.95.234 | 10.200.48.34 |

## Route Tables Summary (8 Total)
| Route Table ID | Name | Type | Associated Subnet Names | Key Routes |
|----------------|------|------|------------------------|------------|
| rtb-0ea550a05aaea0d96 | privateServicesRouteTable | Private | private-subnet-service-1, private-subnet-service-2 | 0.0.0.0/0 → NAT, TGW routes, VPC peering |
| rtb-0427195ca0f4313b9 | privateRouteTable | Private | private-subnet-mongodb-1, private-subnet-1, private-subnet-2, utilities-subnet, private-subnet-mongodb-2, private-subnet-mongodb-3, private-subnet-3 | 0.0.0.0/0 → NAT, TGW routes, VPC peering |
| rtb-02648bf68c0a532c2 | publicServicesRouteTable | Public | pub-subnet-services-1, pub-subnet-services-2 | 0.0.0.0/0 → IGW, TGW routes |
| rtb-0bee4f4f23da64546 | Main Route Table | Main | Default (unassociated subnets) | Local, S3 VPC endpoint |
| rtb-0715ba274d7cd3e9c | privateSolrRouteTable | Private | private-subnet-solr-3, private-subnet-solr-2, private-subnet-solr-1 | 0.0.0.0/0 → NAT, TGW routes |
| rtb-0cfc656d995405bf0 | publicRouteTable | Public | pub-subnet-5, pub-subnet-1, pub-subnet-6, pub-subnet-2, pub-subnet-3, pub-subnet-4 | 0.0.0.0/0 → IGW, TGW routes |
| rtb-09ae23783d865a020 | publicSOLRRouteTable | Public | public-subnet-solr-1 | 0.0.0.0/0 → IGW, TGW routes |

## Transit Gateway & VPC Peering Connections
| Connection Type | ID | Destination CIDR | Purpose |
|-----------------|----|--------------------|---------|
| Transit Gateway | tgw-03cf07cee40ee201c | Multiple on-prem CIDRs | On-premises connectivity |
| VPC Peering | pcx-01e94d49389ae3576 | 10.200.0.0/20 | Cross-VPC communication |
| VPC Peering | pcx-06d1206a779b64614 | 10.200.16.0/20 | Cross-VPC communication |
| VPC Peering | pcx-07a3c631a0d6c4bfc | 10.200.32.0/20 | Cross-VPC communication |
| VPC Peering | pcx-0e6024aa0e10a787c | 10.201.0.0/16 | Cross-VPC communication |
| VPC Peering | pcx-0213560495c0085f1 | 10.244.64.0/20 | Cross-VPC communication |

## VPC Endpoints
| Endpoint ID | Service | Type |
|-------------|---------|------|
| vpce-03710268ce9ab137d | S3 | Gateway |

## DR Replication Requirements Summary

### Critical Components for DR:
1. **VPC**: vpc-05328bd281599ebe3 with CIDR 10.200.48.0/20
2. **Subnets**: 24 subnets across 3 AZs (us-east-1a, us-east-1b, us-east-1c)
3. **Security Groups**: 18 security groups with specific application rules
4. **Internet Gateway**: igw-04b02960a4dacc4de
5. **NAT Gateway**: nat-019818dce532fa289 in public subnet
6. **Route Tables**: 8 route tables with complex routing to TGW and VPC peering
7. **EC2 Instances**: 19 instances across multiple subnets and AZs
8. **Transit Gateway**: tgw-03cf07cee40ee201c for on-premises connectivity
9. **VPC Peering**: 5 peering connections for cross-VPC communication
10. **VPC Endpoint**: S3 gateway endpoint for private S3 access

### Key Dependencies:
- Transit Gateway routes for on-premises connectivity
- VPC peering connections for cross-environment communication
- NAT Gateway for private subnet internet access
- Security group interdependencies between application tiers
- Route table associations for proper traffic flow

This infrastructure supports a multi-tier application with MongoDB, Solr, AEM, and various services distributed across multiple availability zones for high availability.
