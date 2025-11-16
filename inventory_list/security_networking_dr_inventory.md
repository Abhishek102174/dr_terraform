# Security & Networking DR Inventory - US-East-1

## Executive Summary
Complete security and networking infrastructure inventory for disaster recovery planning, covering 30+ security groups, network ACLs, and 5 active VPC peering connections supporting the 19 EC2 instances across 3 VPCs.

## Security Groups Analysis

### Primary VPC Security Groups (vpc-05328bd281599ebe3)

#### Core Application Security Groups

**1. Solr-ZooKeeper Security Group (sg-0d6f14427cf61ca35)**
- **Purpose**: Solr cluster and ZooKeeper coordination
- **Key Ports**: 
  - 2181 (ZooKeeper client)
  - 2888-3888 (ZooKeeper cluster)
  - 8983 (Solr)
  - 2049 (EFS)
- **Cross-references**: Services SG, AEM SG
- **External Access**: Waters on-premises networks, cross-environment indexing

**2. Services Application Security Group (sg-04ca57f9bac9c1bb1)**
- **Purpose**: Microservices and application containers
- **Key Ports**: 
  - 0-65535 (Dynamic Docker ports from ELBs)
  - 1521 (Oracle DB)
  - 3300 (SAP APO)
- **Cross-references**: Services ELB, Internal ELB
- **External Access**: Waters networks, GitHub runners, SAP systems

**3. MongoDB Security Group (sg-0a4c6e59268dc6397)**
- **Purpose**: MongoDB cluster database access
- **Key Ports**: 27017 (MongoDB)
- **Cross-references**: Services SG, self-referencing for cluster
- **External Access**: Waters networks, MuleSoft, CloudHub 2.0, GitHub runners

**4. AEM Author Security Group (sg-0f35db329ea74062c)**
- **Purpose**: AEM Author instances
- **Key Ports**: 
  - 4502 (AEM Author)
  - 9999, 8686 (JMX monitoring)
- **Cross-references**: Dispatcher SG
- **External Access**: Waters networks, cross-environment AEM access

**5. AEM Publish Security Group (sg-08c2f6a34480cf272)**
- **Purpose**: AEM Publish instances
- **Key Ports**: 
  - 4503, 4505 (AEM Publish/Preview)
  - 9999, 8686 (JMX monitoring)
- **Cross-references**: Dispatcher SG, Author SG
- **External Access**: Waters networks

**6. Dispatcher Security Group (sg-0e82f1b6a652cb76b)**
- **Purpose**: Public-facing web servers
- **Key Ports**: 
  - 80, 443 (HTTP/HTTPS)
  - 2812 (Monit)
- **Cross-references**: ELB SGs, Internal ELB, Author/Publish SGs
- **External Access**: Waters networks, ELB traffic

#### Load Balancer Security Groups

**7. External ELB Security Group (sg-081585538c4d1cb66)**
- **Purpose**: Internet-facing load balancer
- **Key Ports**: 80, 443 (HTTP/HTTPS)
- **External Access**: Global CDN networks, specific monitoring IPs
- **Special**: Extensive IP whitelist for CDN and monitoring services

**8. Services ELB Security Group (sg-08f97c3866fc6c08f)**
- **Purpose**: Services load balancer
- **Key Ports**: 80, 443 (HTTP/HTTPS)
- **Cross-references**: Services App SG
- **External Access**: CDN networks, monitoring services

**9. Internal ELB Security Group (sg-0ab6feb35e6b6789e)**
- **Purpose**: Internal load balancer for author access
- **Key Ports**: 
  - 80, 443 (HTTP/HTTPS)
  - 0-65535 (from SearchAdmin NLB)
- **Cross-references**: SearchAdmin NLB, Author SG, Services SG
- **External Access**: Waters VPN networks

**10. SearchAdmin NLB Security Group (sg-03b8920d66cd7535e)**
- **Purpose**: Network load balancer for search admin
- **Key Ports**: 80, 443 (HTTP/HTTPS)
- **External Access**: Private networks (10.0.0.0/8, 172.16.0.0/16)

#### Specialized Security Groups

**11. SFTP Access Security Group (sg-01a97b4eaf45171d7)**
- **Purpose**: SFTP file transfer and EFS access
- **Key Ports**: 
  - 22 (SFTP)
  - 2049 (NFS/EFS)
- **Cross-references**: Author SG (for EFS)
- **External Access**: Waters networks, specific SAP subnets

**12. Third-Party Security Group (sg-00f15d16aad77b85a)**
- **Purpose**: Third-party system access
- **Key Ports**: 22 (SSH)
- **External Access**: 192.150.10.0/24 (third-party network)

**13. SSM Security Group (sg-0ab78fd99a0aa09d3)**
- **Purpose**: AWS Systems Manager access
- **Key Ports**: 443 (HTTPS)
- **External Access**: Local VPC and Waters networks

### Bedrock VPC Security Groups (vpc-053ea1e138fda4494)

**14. MemoryDB Security Group (sg-0799247db1261522d)**
- **Purpose**: Redis/MemoryDB cluster for Bedrock
- **Key Ports**: 6379 (Redis)
- **External Access**: Bedrock VPC CIDR (10.204.0.0/19)

**15. Bedrock Lambda Security Group (sg-0e789543e7bb0ce1e)**
- **Purpose**: Lambda functions for Bedrock processing
- **Ports**: Outbound only
- **External Access**: None (outbound to AWS services)

**16. Bedrock Endpoint Security Group (sg-00d557030ebf44b6d)**
- **Purpose**: VPC endpoint for Bedrock service
- **Key Ports**: 443 (HTTPS)
- **External Access**: Bedrock VPC CIDR (10.204.0.0/19)

**17. VPC Interface Endpoints Security Group (sg-09f934e69f5f899d9)**
- **Purpose**: VPC endpoints for AWS services
- **Key Ports**: 443 (HTTPS)
- **External Access**: Bedrock VPC CIDR (10.204.0.0/19)

**18. Data Ingestion Task Security Group (sg-0ff3ac6e4d95a6f78)**
- **Purpose**: ECS tasks for data ingestion
- **Ports**: Outbound only
- **External Access**: None (outbound to AWS services)

### PrismaCloud VPC Security Groups (vpc-00b0f0ef826a29778)

**19. PrismaCloud Scan Security Group (sg-046c306fb4ff6f42f)**
- **Purpose**: Security scanning infrastructure
- **Ports**: Self-referencing for internal communication
- **External Access**: None (internal scanning only)

## Network ACLs (NACLs)

### Default NACL Configuration
All three VPCs use **default NACLs** with standard allow-all rules:

**Primary VPC NACL (acl-0b3a345a6b59ce60b)**
- **Associated Subnets**: 21 subnets (all primary VPC subnets)
- **Rules**: 
  - Inbound: Allow all (0.0.0.0/0, Rule 100)
  - Outbound: Allow all (0.0.0.0/0, Rule 100)
  - Default Deny: Rule 32767

**Bedrock VPC NACL (acl-0a311cefe7f0ee62e)**
- **Associated Subnets**: 4 subnets (all Bedrock VPC subnets)
- **Rules**: Same default allow-all configuration

**PrismaCloud VPC NACL (acl-002e7f45c562fc851)**
- **Associated Subnets**: 1 subnet
- **Rules**: Same default allow-all configuration

### NACL Security Implications
- **No Custom Restrictions**: All VPCs rely on Security Groups for traffic control
- **Subnet-Level Protection**: Default NACLs provide no additional filtering
- **DR Consideration**: Simple to replicate (default configurations)

## VPC Peering Connections

### Active Peering Connections (5 Total)

**1. Preprod to MuleSoft New (pcx-0213560495c0085f1)**
- **Local VPC**: vpc-05328bd281599ebe3 (10.200.48.0/20)
- **Remote VPC**: vpc-08f542e7c70cf7e1c (10.244.64.0/20)
- **Remote Account**: 494141260463
- **Purpose**: MuleSoft integration connectivity
- **Status**: Active

**2. Preprod to Production (pcx-01e94d49389ae3576)**
- **Local VPC**: vpc-05328bd281599ebe3 (10.200.48.0/20)
- **Remote VPC**: vpc-054bc0a4948a95060 (10.200.0.0/20)
- **Remote Account**: 204142478968
- **Purpose**: Cross-environment connectivity
- **Status**: Active

**3. Cross-Account Peering 1 (pcx-0e6024aa0e10a787c)**
- **Local VPC**: vpc-05328bd281599ebe3 (10.200.48.0/20)
- **Remote VPC**: vpc-09e25897f1bab400b (10.201.0.0/16)
- **Remote Account**: 476384701869
- **Purpose**: Extended network connectivity
- **Status**: Active
- **IPv6**: Enabled (2600:1f18:4fd7:d300::/56)

**4. Cross-Account Peering 2 (pcx-06d1206a779b64614)**
- **Local VPC**: vpc-05328bd281599ebe3 (10.200.48.0/20)
- **Remote VPC**: vpc-05e8f2210189a644b (10.200.16.0/20)
- **Remote Account**: 570400125078
- **Purpose**: Network extension
- **Status**: Active

**5. Cross-Account Peering 3 (pcx-07a3c631a0d6c4bfc)**
- **Local VPC**: vpc-05328bd281599ebe3 (10.200.48.0/20)
- **Remote VPC**: vpc-0e06ea1f64766ddf1 (10.200.32.0/20)
- **Remote Account**: 903879511348
- **Purpose**: Network extension
- **Status**: Active

### Peering Configuration Notes
- **DNS Resolution**: Disabled on all connections
- **Classic Link**: Disabled (not applicable)
- **Cross-Account**: 4 of 5 connections are cross-account
- **CIDR Overlap**: Managed through routing tables

## Security Group Dependencies

### Critical Cross-References
1. **Solr-ZK ↔ Services**: ZooKeeper and Solr access
2. **Services ↔ MongoDB**: Database connectivity
3. **Author ↔ Dispatcher**: Content management flow
4. **Publish ↔ Dispatcher**: Content delivery flow
5. **ELBs ↔ Application SGs**: Load balancer traffic flow
6. **SFTP ↔ Author**: EFS file sharing

### External Network Access Patterns
- **Waters On-Premises**: 10.2.0.0/16, 10.242.0.0/17, 10.242.128.0/17
- **Waters VPN**: 10.249.200.0/21, 10.104.0.0/16, 10.135.208.0/20
- **Waters Extended**: 10.105.0.0/16, 10.231.0.0/16, 10.216.0.0/16
- **GitHub Runners**: 10.201.11.0/24, 10.201.0.0/16
- **MuleSoft**: 10.244.64.0/20, 10.244.96.0/20
- **SAP Systems**: 10.243.0.0/16, 10.243.130.0/24, 10.243.131.0/24
- **Third-Party**: 192.150.10.0/24, 192.139.20.0/24, 192.168.139.0/24

## DR Replication Requirements

### Security Group Replication Priority

**High Priority (Critical Path)**
1. Solr-ZK Security Group (cluster coordination)
2. MongoDB Security Group (database access)
3. Services Application Security Group (microservices)
4. Dispatcher Security Group (public access)
5. ELB Security Groups (load balancing)

**Medium Priority (Supporting Services)**
1. Author/Publish Security Groups (content management)
2. Internal ELB Security Group (internal access)
3. SFTP Access Security Group (file operations)

**Low Priority (Monitoring/Management)**
1. SSM Security Group (management)
2. Third-Party Security Group (external access)
3. Bedrock-related Security Groups (if Bedrock DR needed)

### Cross-Account Dependencies
- **5 VPC Peering Connections** require coordination with remote accounts
- **Cross-account security group references** need account ID updates
- **Remote VPC CIDRs** must be accessible in DR region

### Network ACL Considerations
- **Default NACLs**: Simple to replicate (no custom rules)
- **No Additional Complexity**: Security Groups handle all filtering
- **Subnet Associations**: Must match subnet deployment order

### Security Group Rule Complexity
- **Self-Referencing Rules**: 8 security groups reference themselves
- **Cross-SG References**: 15+ cross-references between security groups
- **External CIDR Blocks**: 20+ unique external network ranges
- **Dynamic Port Ranges**: ELB to services (0-65535)

## Recovery Testing Requirements

### Security Validation
1. **Cross-SG Communication**: Test all security group references
2. **External Network Access**: Verify Waters network connectivity
3. **VPC Peering**: Confirm cross-account peering establishment
4. **Load Balancer Flow**: Test ELB to application connectivity
5. **Database Access**: Verify MongoDB cluster communication
6. **File System Access**: Test EFS connectivity via SFTP SG

### Network Connectivity Tests
1. **Solr Cluster**: ZooKeeper coordination (ports 2181, 2888-3888)
2. **MongoDB Replication**: Cluster communication (port 27017)
3. **AEM Communication**: Author to Publish (ports 4502-4505)
4. **External Access**: Dispatcher HTTP/HTTPS (ports 80, 443)
5. **Management Access**: SSH from Waters networks (port 22)

### Cross-Account Coordination
1. **Peering Acceptance**: Remote account approval required
2. **Route Table Updates**: Both sides of peering connections
3. **Security Group Updates**: Account ID references in rules
4. **DNS Resolution**: Coordinate if cross-VPC DNS needed

---
*Generated: November 11, 2025*  
*Profile: preprod*  
*Region: us-east-1*  
*Security Groups: 30+*  
*VPC Peering Connections: 5 Active*
