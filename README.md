## aws_lifecycle_tools
Repository collecting various tools for using Puppet in Amazon

These scripts and code here are provided as a work in progress,
and meant to allow for community members to update and collaborate
on common tooling for handling Puppet nodes in AWS.

Initial released in Jan of 2016, these scripts were created as part
of this [AWS Whitepaper](http://info.puppetlabs.com/GL-2016-01-WC-1873-AWS-Whitepaper_Registration.html).

## Contents

* certsigner.rb
  example certsigner to be used for policy based autosigning with trusted data
* certsigner_addtags.json
  IAM profile to allow certsigner to update tags
* cloud_provisioner_user.pp
  (untested) module to create a nonroot user for use with [puppetlabs/aws](https://forge.puppetlabs.com/puppetlabs/aws)
* create_trusted_rule.sh
  for PE users, a way to create trusted rules in the NC via API
* userdata
  example userdata scripts for redhat and windows


### Disclaimer
This is meant as example code to be used as a reference, not strictly considered
vetted for security and ready for production environment, but is a starting point
