#!/bin/bash
# Solr Production Environment User Data Script

yum update -y

# Mount data volume
if ! mountpoint -q /opt/solr/data; then
  mkfs -t ext4 /dev/xvdf
  mkdir -p /opt/solr/data
  mount /dev/xvdf /opt/solr/data
  echo '/dev/xvdf /opt/solr/data ext4 defaults,nofail 0 2' >> /etc/fstab
fi

# Set ownership
chown -R solr:solr /opt/solr/data

# Configure Solr for Production
echo "ENVIRONMENT=${environment}" >> /opt/solr/bin/solr.in.sh
echo "PROD_REGION=${region}" >> /opt/solr/bin/solr.in.sh
echo "SOLR_HEAP=8g" >> /opt/solr/bin/solr.in.sh  # Larger heap for production

# Production-specific optimizations
echo "SOLR_GC_TUNE=\"-XX:+UseG1GC -XX:+UseStringDeduplication\"" >> /opt/solr/bin/solr.in.sh

# Enable monitoring
echo "ENABLE_REMOTE_JMX_OPTS=true" >> /opt/solr/bin/solr.in.sh

# Start Solr service
systemctl enable solr
systemctl start solr

# Log deployment
echo "$(date): Solr Production instance initialized in ${environment}" >> /var/log/solr-prod.log
