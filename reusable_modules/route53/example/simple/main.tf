provider "aws" {
 region = "us-east-1"
}
# Create VPC for private zone association
resource "aws_vpc" "private" {
 cidr_block           = "10.0.0.0/16"
 enable_dns_support   = true
 enable_dns_hostnames = true
 tags = {
   Name = "private-zone-vpc"
 }
}
data "aws_region" "current" {}
# Public hosted zone with records
module "public_zone" {
 source               = "../../"
 domain_name          = "public.waters.com"
 health_check_fqdn    = "app.public.waters.com"
 health_check_regions = ["us-east-1", "eu-west-1", "us-west-2"]
 tags = {
   Environment = "sandbox"
 }
 records = [
   # Simple A record
   {
     name    = "www"
     type    = "A"
     ttl     = 300
     records = ["192.0.2.1", "192.0.2.2"]
   },
   # MX record for email
   {
     name    = "@"
     type    = "MX"
     ttl     = 3600
     records = ["10 mailserver1.public.waters.com.", "20 mailserver2.public.waters.com."]
   },
   # Alias to CloudFront
   {
     name = "cdn"
     type = "A"
     alias = {
       name    = "d123abcxyz.cloudfront.net"
       zone_id = "Z2FDTNDATAQYW2"
     }
   },
   # Weighted record
   {
     name            = "api"
     type            = "CNAME"
     ttl             = 300
     records = ["elb-primary.public.waters.com."]
   }
 ]
}
# Private hosted zone with VPC association and records
module "private_zone" {
 source       = "../../"
 domain_name  = "private.waters.net"
 private_zone = true
 vpc_associations = [{
   vpc_id     = aws_vpc.private.id
   vpc_region = data.aws_region.current.name
 }]
 comment = "Internal services"
 tags = {
   Environment = "internal"
 }
 records = [
   # Internal service record
   {
     name    = "database"
     type    = "CNAME"
     ttl     = 300
     records = ["db.internal.cluster.private.waters.net."]
   },
   # Private API endpoint
   {
     name    = "api"
     type    = "A"
     ttl     = 60
     records = ["10.0.1.10", "10.0.1.11"]
   },
   # Private service alias to NLB (using correct NLB zone ID)
   {
     name = "internal-service"
     type = "A"
     alias = {
       name                   = "internal-nlb-123456789.elb.us-east-1.amazonaws.com"
       zone_id                = "Z26RNL4JYFTOTI"  # NLB zone ID for us-east-1
       evaluate_target_health = true
     }
   }
 ]
}
# HTTPS health check with records
module "https_health_check" {
 source               = "../../"
 domain_name          = "monitored.waters.com"
 health_check_fqdn    = "api.monitored.waters.com"
 enable_https         = true
 health_check_path    = "/health"
 health_check_regions = ["us-west-2", "ap-southeast-1", "eu-west-1"]
 records = [
   # Failover primary record
   {
     name            = "app"
     type            = "A"
     set_identifier  = "primary"
     failover_routing_policy = {
       type = "PRIMARY"
     }
     alias = {
       name    = "d-prod.cloudfront.net"
       zone_id = "Z2FDTNDATAQYW2"
     }
   },
   # Failover secondary record
   {
     name            = "app"
     type            = "A"
     set_identifier  = "secondary"
     failover_routing_policy = {
       type = "SECONDARY"
     }
     alias = {
       name    = "d-backup.cloudfront.net"
       zone_id = "Z2FDTNDATAQYW2"
     }
   },
   # Simple TXT record
   {
     name    = "_domainkey"
     type    = "TXT"
     ttl     = 600
     records = ["k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDD..."]
   }
 ]
}