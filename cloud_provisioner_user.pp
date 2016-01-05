user {'awsprovisioner':
  ensure => present,
  managehome => true,
  password => 'something',
}

File{
  owner => awsprovisioner,
  group => awsprovisioner,
  mode => 0700,
  require => User['awsprovisioner']
}

file {[
  '/home/awsprovisioner/.puppetlabs',
  '/home/awsprovisioner/.puppetlabs/puppet',
  '/home/awsprovisioner/.aws'
  ]:
  ensure => directory,
}

file {'/home/awsprovisioner/.puppetlabs/puppet/puppet.conf':
  ensure => present,
}

file {'/home/awsprovisioner/.aws/credentials':
  ensure => present,
}

ini_setting {'awsprovisioner puppet servername':
  ensure => present,
  path => '/home/awsprovisioner/.puppetlabs/puppet/puppet.conf',
  section => 'agent',
  setting => 'server',
  value => $::servername,
  require => File['/home/awsprovisioner/.puppetlabs/puppet/puppet.conf']
}
ini_setting {'awsprovisioner puppet certname':
  ensure => present,
  path => '/home/awsprovisioner/.puppetlabs/puppet/puppet.conf',
  section => 'agent',
  setting => 'certname',
  value => "${::fqdn}-awsprovisioner",
  require => File['/home/awsprovisioner/.puppetlabs/puppet/puppet.conf']
}

$cron_1 = fqdn_rand('30','awsprovisioner')
$cron_2 = fqdn_rand('30','awsprovisioner') + 30

cron { 'cron.puppet.awsprovisioner':
  command => '/opt/puppetlabs/puppet/bin/puppet agent --onetime --no-daemonize',
  user    => 'awsprovisioner',
  minute  => [ $cron_1, $cron_2 ],
  require => File['/home/awsprovisioner/.puppetlabs'],
}

package { 'aws-sdk-core':
  ensure => present,
  provider => puppet_gem,
}
