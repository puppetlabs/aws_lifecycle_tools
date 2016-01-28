<powershell>
$webclient = New-Object System.Net.WebClient

#Customize $PUPPET_MASTER and $PUPPET_CERTNAME per environment as needed
#Update PUPPET_AIO_VERSION as needed (It is suggested to host your own msi)

$PUPPET_MASTER       = 'ip-10-98-10-13.us-west-2.compute.internal'
$PUPPET_AIO_VERSION  = '1.2.5'

$PUPPET_AIO_PLATFORM = 'x64'
$PUPPET_MSI          = "puppet-agent-$PUPPET_AIO_VERSION-$PUPPET_AIO_PLATFORM.msi"

$AWS_SERVER          = 'http://169.254.169.254'
$INSTALLER_URL       = "http://downloads.puppetlabs.com/windows/$PUPPET_MSI"
$INSTALLER_TEMP_FILE = [IO.Path]::GetTempFileName()
$INSTALLER_LOG_FILE  = [IO.Path]::GetTempFileName()
$PUPPET_PATH         = 'c:\ProgramData\PuppetLabs\puppet\etc'
$PUPPET_CSR_FILE     = Join-Path $PUPPET_PATH 'csr_attributes.yaml'

$PP_IMAGE_NAME       = $webclient.DownloadString("$AWS_SERVER/latest/meta-data/ami-id")
$AWS_INSTANCE_ID     = $webclient.DownloadString("$AWS_SERVER/latest/meta-data/instance-id")

$PUPPET_CERTNAME     = $AWS_INSTANCE_ID
$PP_INSTANCE_ID      = $AWS_INSTANCE_ID

# download MSI to temp file
$webclient.DownloadFile($INSTALLER_URL, $INSTALLER_TEMP_FILE)

# Create the directory
New-Item -Path $PUPPET_PATH -ItemType Directory -Force

# these are all the OIDs that we may map or already have
# https://docs.puppetlabs.com/puppet/latest/reference/ssl_attributes_extensions.html
Set-Content -Path $PUPPET_CSR_FILE -Encoding UTF8 -Force -Value @"
extension_requests:
  pp_instance_id: $PP_INSTANCE_ID
  pp_image_name: $PP_IMAGE_NAME
  1.3.6.1.4.1.34380.1.1.13: 'windowswebserver'
  1.3.6.1.4.1.34380.1.1.18: 'us-west-2'
"@

#install the MSI, look at $INSTALLER_LOG_FILE for any errors
msiexec /qn /i $INSTALLER_TEMP_FILE /l*vx $INSTALLER_LOG_FILE PUPPET_MASTER_SERVER="$PUPPET_MASTER" PUPPET_AGENT_CERTNAME="$PUPPET_CERTNAME"
</powershell>
