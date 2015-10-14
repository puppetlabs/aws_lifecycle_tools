#!/bin/bash

# this is a simple script to create a one rule group in the Node Manager via
# api calls.
# it is meant to be executed as root on the host running the console services
# ./create_trusted_rule.sh $trusted_extension $trusted_value creates a new node group
# with the namae Trusted_$trusted_extension which you can then edit in the UI

#user inputs
trusted_extension=$1
trusted_value=$2

#environment information
PATH=/opt/puppetlabs/bin/:$PATH

console_fqdn=$(facter fqdn)
cert=$(puppet config print hostcert)
key=$(puppet config print hostprivkey)
cacert=$(puppet config print localcacert)

read -r -d '' trusted_call << RULE_JSON
{
    "name": "Trusted_$trusted_value",
    "classes": {},
    "environment": "production",
    "environment_trumps": false,
    "parent": "00000000-0000-4000-8000-000000000000",
    "rule": [ "=",
          [ "trusted", "extensions", "$trusted_extension" ],
          "$trusted_value"
        ],
    "variables": {}
}
RULE_JSON

curl -X POST -H "Content-type: application/json" \
--dump-header - \
--location \
--data "$trusted_call" \
--cert   $cert \
--key    $key \
--cacert $cacert \
https://$console_fqdn:4433/classifier-api/v1/groups
