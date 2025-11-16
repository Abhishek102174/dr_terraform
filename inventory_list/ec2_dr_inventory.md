# EC2 Disaster Recovery Inventory - US-East-1
**Generated:** 2025-11-11T15:40:00Z  
**Environment:** preprod  
**VPC:** vpc-05328bd281599ebe3  

## Summary
- **Total Instances:** 19
- **Running:** 18
- **Stopped:** 1
- **Availability Zones:** us-east-1a (8), us-east-1b (6), us-east-1c (5)

---

## Instance Inventory

### 1. DISPATCHER SERVICES (3 instances)

#### i-07b03972248bc5cc3 - dispatcher-author
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-0e2ba2a8f61130207
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.50.121
- **Public IP:** 54.164.203.58
- **Subnet:** subnet-022849cb3176e54f8
- **Security Groups:** sg-0e82f1b6a652cb76b (dispatcher-sg)
- **ENI:** eni-0ad4dedea128d2a87
- **Volumes:** vol-0b9a299f4ab0da61e (/dev/sda1)
- **Service:** dispatcher
- **Environment:** preprod

#### i-06706dad5f8f38ea2 - dispatcher
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-0cd80cc197e2af7d1
- **AZ:** us-east-1b
- **Key Pair:** waters-key
- **Private IP:** 10.200.49.178
- **Public IP:** 98.94.9.198
- **Subnet:** subnet-03d3acf7999f8f633
- **Security Groups:** sg-0e82f1b6a652cb76b (dispatcher-sg)
- **ENI:** eni-02e1bc7f99c46eacf
- **Volumes:** vol-02068080e0a48b697 (/dev/sda1)
- **Service:** aem
- **Environment:** preprod

#### i-0632992ca2d1a4a80 - dispatcher
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-017396d40104033c1
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.49.87
- **Public IP:** 3.95.192.199
- **Subnet:** subnet-0c8d9f5161d769f89
- **Security Groups:** sg-0e82f1b6a652cb76b (dispatcher-sg)
- **ENI:** eni-052714672c6b41c49
- **Volumes:** vol-0ab6d7dcf9a79c6d1 (/dev/sda1)
- **Service:** aem
- **Environment:** preprod

---

### 2. ZOOKEEPER CLUSTER (3 instances)

#### i-0c2b1ba435b259a3f - zk
- **State:** RUNNING
- **Type:** m5.large
- **AMI:** ami-098f16afa9edf40be
- **AZ:** us-east-1a
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.58.50
- **Subnet:** subnet-06196bd305caf4c5f
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-0bc46b7944a2b0425
- **Volumes:** vol-0d170d481552f69ac (/dev/sda1)
- **Service:** zk
- **Environment:** preprod

#### i-00385cfd33f9d360b - zk
- **State:** RUNNING
- **Type:** m5.large
- **AMI:** ami-098f16afa9edf40be
- **AZ:** us-east-1b
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.58.150
- **Subnet:** subnet-0033079c8d034f06b
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-0928609d34e6c386d
- **Volumes:** vol-03fe0260d23b4a731 (/dev/sda1)
- **Service:** zk
- **Environment:** preprod

#### i-06e98bc20a1ae8229 - zk
- **State:** RUNNING
- **Type:** m5.large
- **AMI:** ami-098f16afa9edf40be
- **AZ:** us-east-1c
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.59.50
- **Subnet:** subnet-08a2cccea280e8f85
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-030211fcf6efffccd
- **Volumes:** vol-0353ab7ea107aa7de (/dev/sda1)
- **Service:** zk
- **Environment:** preprod

---

### 3. MONGODB CLUSTER (3 instances)

#### i-02d38ea6976dc1516 - mongodb
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-0be2609ba883822ec
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.53.10
- **Subnet:** subnet-0ee11af069b22e4ea
- **Security Groups:** sg-0a4c6e59268dc6397 (mongodb-sg)
- **ENI:** eni-0be9793f36e1c7231
- **Volumes:** vol-08a1135ab485ee1b9 (/dev/xvda)
- **Service:** mongoDB
- **Environment:** preprod

#### i-07190d40c5e22269c - mongodb
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-0be2609ba883822ec
- **AZ:** us-east-1b
- **Key Pair:** waters-key
- **Private IP:** 10.200.53.56
- **Subnet:** subnet-0d067d4bc3e0fab23
- **Security Groups:** sg-0a4c6e59268dc6397 (mongodb-sg)
- **ENI:** eni-046e0a3080b1c59b6
- **Volumes:** vol-0653eab4ecdd69150 (/dev/xvda)
- **Service:** mongoDB
- **Environment:** preprod

#### i-047141fb7a8c0f7b6 - mongodb
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-0be2609ba883822ec
- **AZ:** us-east-1c
- **Key Pair:** waters-key
- **Private IP:** 10.200.53.79
- **Subnet:** subnet-0b6d14dd3ab2bf70f
- **Security Groups:** sg-0a4c6e59268dc6397 (mongodb-sg)
- **ENI:** eni-03109eea7a0ad51f3
- **Volumes:** vol-06bf935e892171d3c (/dev/xvda)
- **Service:** mongoDB
- **Environment:** preprod

---

### 4. SOLR CLUSTER (3 instances)

#### i-07c3e1034fbfb7781 - solr
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-039450cfa5dcd04c7
- **AZ:** us-east-1c
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.59.114
- **Subnet:** subnet-08a2cccea280e8f85
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-03cba7e351e5001ee
- **Volumes:** 
  - vol-01ae3084773f7a1f9 (/dev/sda1)
  - vol-08ca002885da063d4 (/dev/xvdf)
- **Service:** solr
- **Environment:** preprod

#### i-049f9846990563b0e - solr
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-039450cfa5dcd04c7
- **AZ:** us-east-1b
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.58.146
- **Subnet:** subnet-0033079c8d034f06b
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-0dfe66eb8aa2c9d72
- **Volumes:** 
  - vol-000069951d962fd5d (/dev/sda1)
  - vol-001397568348e056e (/dev/xvdf)
- **Service:** solr
- **Environment:** preprod

#### i-08676378458626547 - solr
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-039450cfa5dcd04c7
- **AZ:** us-east-1a
- **Key Pair:** waters-key-solr
- **Private IP:** 10.200.58.65
- **Subnet:** subnet-06196bd305caf4c5f
- **Security Groups:** sg-0d6f14427cf61ca35 (solr-zk-sg)
- **ENI:** eni-0e8be5a1b834e35a6
- **Volumes:** 
  - vol-0b1e54a7874473990 (/dev/sda1)
  - vol-014daa51c9b98a700 (/dev/xvdf)
- **Service:** solr
- **Environment:** preprod

---

### 5. AEM SERVICES (3 instances)

#### i-0f881ff9db3b73b0a - author
- **State:** RUNNING
- **Type:** m5.2xlarge
- **AMI:** ami-0d86b557cbf316c39
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.52.50
- **Subnet:** subnet-0ed904e4b8afc8475
- **Security Groups:** sg-0f35db329ea74062c (author-sg)
- **ENI:** eni-01620dfb8183d1804
- **Volumes:** 
  - vol-02e7ae623da9c1e18 (/dev/sda1)
  - vol-0f45f8db87e26ca26 (/dev/sdf)
- **Service:** author
- **Environment:** preprod

#### i-0e8c27b42097bf437 - publish
- **State:** RUNNING
- **Type:** m5.2xlarge
- **AMI:** ami-0620c74327207aaff
- **AZ:** us-east-1b
- **Key Pair:** waters-key
- **Private IP:** 10.200.51.229
- **Subnet:** subnet-0f5840096e9ce7b33
- **Security Groups:** sg-08c2f6a34480cf272 (publish-sg)
- **ENI:** eni-0d6d71b43b80402eb
- **Volumes:** 
  - vol-078360fcb28230fb5 (/dev/sda1)
  - vol-0f31a42d47f128417 (/dev/sdf)
- **Service:** aem (publish)
- **Environment:** preprod

#### i-08eb676fda7eecdaf - publish
- **State:** RUNNING
- **Type:** m5.2xlarge
- **AMI:** ami-0f33e2d33fd124126
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.51.43
- **Subnet:** subnet-06d7d17c5e6be647c
- **Security Groups:** sg-08c2f6a34480cf272 (publish-sg)
- **ENI:** eni-053d51bc02ee16a8f
- **Volumes:** 
  - vol-0e44c19ee9ffd7b88 (/dev/sda1)
  - vol-03a14ebed0164c855 (/dev/sdf)
- **Service:** aem (publish)
- **Environment:** preprod

---

### 6. MICROSERVICES (2 instances)

#### i-02ecc7b5d54cf8a4d - services
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-00678b231e70de8b0
- **AZ:** us-east-1b
- **Key Pair:** waters-key-services
- **Private IP:** 10.200.56.152
- **Subnet:** subnet-016e889b35a2f53a1
- **Security Groups:** sg-04ca57f9bac9c1bb1 (service-app-sg)
- **ENI:** eni-0ad9e872ee49402db
- **Volumes:** vol-07107f10d3618bdd4 (/dev/xvda)
- **Service:** services
- **Environment:** preprod

#### i-04be2f4a32a3ccf7a - services
- **State:** RUNNING
- **Type:** m5.xlarge
- **AMI:** ami-00678b231e70de8b0
- **AZ:** us-east-1a
- **Key Pair:** waters-key-services
- **Private IP:** 10.200.56.32
- **Subnet:** subnet-0851ebcd3bb17e7be
- **Security Groups:** sg-04ca57f9bac9c1bb1 (service-app-sg)
- **ENI:** eni-06e277253137edd51
- **Volumes:** vol-0e8a276f6be2f39fa (/dev/xvda)
- **Service:** services
- **Environment:** preprod

---

### 7. STOPPED INSTANCES (1 instance)

#### i-0b267d9b2c1803127 - chemadvisor-bedrock-preprod
- **State:** STOPPED
- **Type:** t2.medium
- **AMI:** ami-00627c95ca6a45efb
- **AZ:** us-east-1a
- **Key Pair:** waters-key
- **Private IP:** 10.200.53.27
- **Subnet:** subnet-0ee11af069b22e4ea
- **Security Groups:** sg-0a4c6e59268dc6397 (mongodb-sg)
- **ENI:** eni-0f6d9a577794aa0fb
- **Volumes:** vol-0da8e1c4bf2da9801 (/dev/sda1)
- **Service:** bedrock (experimental)
- **Environment:** preprod

---

## DR Recovery Considerations

### Key Pairs Required:
- **waters-key** (primary key for most services)
- **waters-key-solr** (for Solr/ZK cluster)
- **waters-key-services** (for microservices)

### Security Groups:
- **sg-0e82f1b6a652cb76b** (dispatcher-sg)
- **sg-0d6f14427cf61ca35** (solr-zk-sg)
- **sg-0a4c6e59268dc6397** (mongodb-sg)
- **sg-0f35db329ea74062c** (author-sg)
- **sg-08c2f6a34480cf272** (publish-sg)
- **sg-04ca57f9bac9c1bb1** (service-app-sg)

### Critical Dependencies:
1. **ZooKeeper cluster** must be restored first (3 nodes across AZs)
2. **MongoDB cluster** for data persistence (3 nodes across AZs)
3. **Solr cluster** depends on ZooKeeper (3 nodes with additional storage)
4. **AEM services** (Author + 2 Publish instances with additional storage)
5. **Dispatcher services** (3 instances with public IPs)
6. **Microservices** (2 instances for load balancing)

### Network Configuration:
- **VPC:** vpc-05328bd281599ebe3
- **Multi-AZ deployment** across us-east-1a, us-east-1b, us-east-1c
- **Public IPs** only on dispatcher instances for external access
- **Private subnets** for backend services

### Volume Dependencies:
- **Additional storage volumes** on Solr and AEM instances (/dev/sdf, /dev/xvdf)
- **Root volumes** vary by service type (/dev/sda1, /dev/xvda)

---

**Total EBS Volumes:** 25 volumes across 19 instances  
**Public IPs:** 3 (all dispatcher instances)  
**Cost Center:** WG09 (all instances)  
**Management:** Terraform-managed infrastructure
