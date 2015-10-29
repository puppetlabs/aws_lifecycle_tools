<powershell>
$webclient = new-object System.Net.WebClient

$PE_MASTER = 'ip-10-98-10-13.us-west-2.compute.internal'

$AWS_INSTANCE_ID = $webclient.DownloadString("http://169.254.169.254/latest/meta-data/instance-id")

$PE_CERTNAME = "windows-$AWS_INSTANCE_ID"

# these are attributes we know already
$PP_INSTANCE_ID = $AWS_INSTANCE_ID

$PP_IMAGE_NAME = $webclient.DownloadString("http://169.254.169.254/latest/meta-data/ami-id")

<%-# these are all the OIDs that we may map or already have -%>
<%-# https://docs.puppetlabs.com/puppet/latest/reference/ssl_attributes_extensions.html -%>
# Create the directory

new-item c:\ProgramData\PuppetLabs\puppet\etc\ -itemtype directory -force

$CSR_ATTRIBUTES = @"
extension_requests:
  pp_instance_id: $PP_INSTANCE_ID
  pp_image_name: $PP_IMAGE_NAME
  1.3.6.1.4.1.34380.1.1.13: 'windowswebserver'
  1.3.6.1.4.1.34380.1.1.18: 'us-west-2'
"@

out-file -filepath c:\ProgramData\PuppetLabs\puppet\etc\csr_attributes.yaml -encoding UTF8 -inputobject $CSR_ATTRIBUTES -force

$INSTALLER_URL = "http://downloads.puppetlabs.com/windows/puppet-agent-1.2.5-x64.msi"

msiexec /qn /i $INSTALLER_URL PUPPET_MASTER_SERVER="$PE_MASTER" PUPPET_AGENT_CERTNAME="$PE_CERTNAME"
</powershell>
