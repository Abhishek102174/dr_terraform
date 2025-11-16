# Load Balancer DR Inventory - US-East-1

## Executive Summary
Complete load balancer infrastructure inventory for disaster recovery planning, covering 4 Application Load Balancers (ALBs) with 6 target groups supporting the distributed application architecture across 2 availability zones.

## Application Load Balancers (ALBs)

### 1. AEM Author Load Balancer
**Basic Configuration**
- **Name**: alb-dispatcher-author
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:loadbalancer/app/alb-dispatcher-author/1fc720bb281d5917
- **Type**: Application Load Balancer (ALB)
- **Scheme**: Internal (private)
- **VPC**: vpc-05328bd281599ebe3
- **State**: Active
- **Created**: September 9, 2020

**Network Configuration**
- **DNS Name**: internal-alb-dispatcher-author-1088490873.us-east-1.elb.amazonaws.com
- **Hosted Zone ID**: Z35SXDOTRQ7X7K
- **IP Address Type**: IPv4
- **Availability Zones**: 
  - us-east-1a (subnet-0dea76d02d90ce122)
  - us-east-1b (subnet-03f8969696f88601a)
- **Security Groups**: sg-0ab6feb35e6b6789e (elb-internal-sg)

**Listeners**
- **HTTP Listener (Port 80)**:
  - Protocol: HTTP
  - Default Action: Redirect to HTTPS (301)
  - Target: Port 443 with same host/path/query
- **HTTPS Listener (Port 443)**:
  - Protocol: HTTPS
  - SSL Certificate: arn:aws:acm:us-east-1:327711378138:certificate/50438db4-e7bd-44a6-8963-9ab99938b127
  - SSL Policy: ELBSecurityPolicy-2016-08
  - Default Action: Forward to dispatcher-author-tg
  - Mutual Authentication: Disabled

**Target Group**: dispatcher-author-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/dispatcher-author-tg/37f55b4987b23d74
- **Protocol**: HTTPS (Port 443)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTPS
  - Port: 443
  - Path: /libs/granite/core/content/login.html
  - Interval: 10 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**Tags**: Name: alb-dispatcher-author

### 2. AEM Publish Load Balancer
**Basic Configuration**
- **Name**: alb-dispatcher-publish
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:loadbalancer/app/alb-dispatcher-publish/c23bc85b96559741
- **Type**: Application Load Balancer (ALB)
- **Scheme**: Internet-facing (public)
- **VPC**: vpc-05328bd281599ebe3
- **State**: Active
- **Created**: September 9, 2020

**Network Configuration**
- **DNS Name**: alb-dispatcher-publish-1297954259.us-east-1.elb.amazonaws.com
- **Hosted Zone ID**: Z35SXDOTRQ7X7K
- **IP Address Type**: IPv4
- **Availability Zones**: 
  - us-east-1a (subnet-0dea76d02d90ce122)
  - us-east-1b (subnet-03f8969696f88601a)
- **Security Groups**: sg-081585538c4d1cb66 (elb-sg)

**Target Group**: dispatcher-publish-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/dispatcher-publish-tg/51645de73722ca17
- **Protocol**: HTTPS (Port 443)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTPS
  - Port: 443
  - Path: /system/health/shallow.json
  - Interval: 15 seconds
  - Timeout: 10 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**Tags**: Name: alb-dispatcher-publish

### 3. ECS Services Load Balancer
**Basic Configuration**
- **Name**: preprod-ecs-cluster-elb
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:loadbalancer/app/preprod-ecs-cluster-elb/38333865a745cb0b
- **Type**: Application Load Balancer (ALB)
- **Scheme**: Internet-facing (public)
- **VPC**: vpc-05328bd281599ebe3
- **State**: Active
- **Created**: November 19, 2020

**Network Configuration**
- **DNS Name**: preprod-ecs-cluster-elb-1804599009.us-east-1.elb.amazonaws.com
- **Hosted Zone ID**: Z35SXDOTRQ7X7K
- **IP Address Type**: IPv4
- **Availability Zones**: 
  - us-east-1a (subnet-082cabe0832e7f826)
  - us-east-1b (subnet-0188200b54d768632)
- **Security Groups**: sg-08f97c3866fc6c08f (services-elb-sg)

**Target Groups**:

**A. Payment Service Target Group**
- **Name**: payment-service-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/payment-service-tg/5d1bc70815e5df0e
- **Protocol**: HTTP (Port 80)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTP
  - Port: traffic-port
  - Path: /api/payment/actuator/health
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**B. ECS Cluster Target Group**
- **Name**: preprod-ecs-cluster-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/preprod-ecs-cluster-tg/a788b3d95b8eabe2
- **Protocol**: HTTP (Port 80)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTP
  - Port: traffic-port
  - Path: /
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**Tags**: 
- app: it-web
- value_stream: web2.0
- iso_location: us
- env: preprod
- created_by: terraform
- version: 1.0
- technical_owner: web2.0
- Terraform: true
- tier: 1
- cost_center: WG09
- Tech-Stack: services
- service: services
- location: north_virginia-us

### 4. Search Admin Internal Load Balancer
**Basic Configuration**
- **Name**: searchadmin-ilb
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:loadbalancer/app/searchadmin-ilb/cb42817dd4b2e8c2
- **Type**: Application Load Balancer (ALB)
- **Scheme**: Internal (private)
- **VPC**: vpc-05328bd281599ebe3
- **State**: Active
- **Created**: January 21, 2022

**Network Configuration**
- **DNS Name**: internal-searchadmin-ilb-186109434.us-east-1.elb.amazonaws.com
- **Hosted Zone ID**: Z35SXDOTRQ7X7K
- **IP Address Type**: IPv4
- **Availability Zones**: 
  - us-east-1a (subnet-082cabe0832e7f826)
  - us-east-1b (subnet-0188200b54d768632)
- **Security Groups**: sg-0ab6feb35e6b6789e (elb-internal-sg)

**Target Groups**:

**A. Search Admin API Target Group**
- **Name**: search-admin-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/search-admin-tg/46f3b3d952ad11d9
- **Protocol**: HTTP (Port 80)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTP
  - Port: traffic-port
  - Path: /searchadmin/api/elevate/list
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**B. Search Admin UI Target Group**
- **Name**: searchadmin-ui-tg
- **ARN**: arn:aws:elasticloadbalancing:us-east-1:327711378138:targetgroup/searchadmin-ui-tg/27102a41dd85b7e6
- **Protocol**: HTTP (Port 80)
- **Target Type**: Instance
- **Health Check**:
  - Protocol: HTTP
  - Port: traffic-port
  - Path: /
  - Interval: 30 seconds
  - Timeout: 5 seconds
  - Healthy Threshold: 5
  - Unhealthy Threshold: 2
  - Success Codes: 200

**Tags**: 
- app: it-web
- value_stream: web2.0
- iso_location: us
- env: preprod
- created_by: terraform
- version: 1.0
- technical_owner: web2.0
- Terraform: true
- tier: 1
- cost_center: WG09
- Tech-Stack: services
- service: services
- location: north_virginia-us

## Load Balancer Architecture Summary

### Traffic Flow Patterns
1. **External Traffic**: Internet → ALB Dispatcher Publish → Dispatcher Instances
2. **Internal Author Traffic**: VPN/Internal → ALB Dispatcher Author → Dispatcher Instances
3. **Microservices Traffic**: Internet → ECS Cluster ELB → Services Instances
4. **Search Admin Traffic**: Internal → Search Admin ILB → Services Instances

### Security Group Associations
- **External ELB SG (sg-081585538c4d1cb66)**: Internet-facing ALBs
- **Internal ELB SG (sg-0ab6feb35e6b6789e)**: Internal ALBs
- **Services ELB SG (sg-08f97c3866fc6c08f)**: ECS services ALB

### SSL/TLS Configuration
- **Author ALB**: SSL termination with ACM certificate
- **Publish ALB**: SSL termination (listeners not detailed in current data)
- **ECS Services ALB**: HTTP only (SSL termination likely at application level)
- **Search Admin ILB**: HTTP only (internal traffic)

## DR Replication Requirements

### High Priority Load Balancers
1. **ALB Dispatcher Publish** (Internet-facing, critical path)
2. **ALB Dispatcher Author** (Internal access, content management)
3. **ECS Cluster ELB** (Microservices, payment processing)

### Medium Priority Load Balancers
1. **Search Admin ILB** (Internal tools, non-critical path)

### Critical Dependencies for DR

**SSL Certificates**
- ACM Certificate: arn:aws:acm:us-east-1:327711378138:certificate/50438db4-e7bd-44a6-8963-9ab99938b127
- Must be replicated or re-issued in DR region

**DNS Configuration**
- Route 53 hosted zone management required
- DNS failover configuration for public ALBs
- Internal DNS resolution for private ALBs

**Target Group Health Checks**
- AEM-specific health check paths (/libs/granite/core/content/login.html, /system/health/shallow.json)
- Microservices health endpoints (/api/payment/actuator/health)
- Search admin API endpoints (/searchadmin/api/elevate/list)

**Security Group Dependencies**
- ELB security groups must be replicated with correct CIDR blocks
- Cross-references to application security groups
- External IP whitelist maintenance for internet-facing ALBs

### Load Balancer Attributes to Replicate
- **Idle Timeout**: Default (60 seconds)
- **Connection Draining**: Default settings
- **Cross-Zone Load Balancing**: Enabled by default for ALBs
- **Access Logs**: Configuration not captured (should be verified)
- **Deletion Protection**: Status not captured (should be verified)

## Recovery Testing Requirements

### Connectivity Tests
1. **External Access**: Verify internet-facing ALB accessibility
2. **Internal Access**: Test VPN/internal network routing to internal ALBs
3. **Health Check Validation**: Confirm all target group health checks pass
4. **SSL Certificate Validation**: Verify certificate installation and trust chain

### Application-Specific Tests
1. **AEM Author**: Login page accessibility (/libs/granite/core/content/login.html)
2. **AEM Publish**: Health check endpoint (/system/health/shallow.json)
3. **Payment Service**: Actuator health endpoint (/api/payment/actuator/health)
4. **Search Admin**: API endpoint accessibility (/searchadmin/api/elevate/list)

### Load Balancer Failover Tests
1. **Target Instance Failure**: Verify automatic target deregistration
2. **Availability Zone Failure**: Test cross-AZ load balancing
3. **Health Check Failure**: Validate unhealthy target removal
4. **SSL Certificate Expiry**: Test certificate renewal process

## Cost Considerations for DR
- **ALB Hourly Costs**: ~$16.20/month per ALB (4 ALBs = ~$65/month)
- **LCU Costs**: Variable based on traffic (connections, requests, bandwidth)
- **Target Group Costs**: No additional charges
- **Health Check Costs**: Included in ALB pricing
- **Cross-AZ Data Transfer**: Additional costs for multi-AZ deployment

---
*Generated: November 11, 2025*  
*Profile: preprod*  
*Region: us-east-1*  
*Load Balancers: 4 ALBs*  
*Target Groups: 6 Total*
