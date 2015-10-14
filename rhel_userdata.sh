#!/bin/bash

#user set variables here for use in the rest of the mani
PUPPET_MASTER='yourpuppetmaster'
PP_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PP_IMAGE_NAME=$(curl -s http://169.254.169.254/latest/meta-data/ami-id)
PP_REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//')
PP_ROLE='webserver'

#this is for Puppet 4 AIO only
PUPPET='/opt/puppetlabs/bin/puppet'

#create the CSR Attributes file before installing the agent
if [ ! -d /etc/puppetlabs/puppet ]; then
    mkdir -p /etc/puppetlabs/puppet
fi

# Until PUP-5535 is live, we use the OID for pp_region

cat > /etc/puppetlabs/puppet/csr_attributes.yaml << YAML
extension_requests:
  pp_instance_id: $PP_INSTANCE_ID
  pp_image_name: $PP_IMAGE_NAME
  1.3.6.1.4.1.34380.1.1.18: $PP_REGION
  pp_role: $PP_ROLE
YAML

#Install the Puppet Agent
rpm -ivh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
yum install -y puppet-agent

$PUPPET config set master $PUPPET_MASTER --section agent
$PUPPET config set certname $INSTANCE_ID --section agent

$PUPPET resource service puppet ensure=running enable=true
