#!/usr/bin/env bash

VPN_VYATTA_TXT_FILE=$1

#**********************
#**********************
#Script used to patch the AWS VPN Vyatta config file
#Updates required due to api change in VYOS 1.2.1 conf

#This script should be executed on the AWS VPN Vyatta config file 
#dowloaded at 7:17 in the "Amazon VPC IPSec VPNs - Dynamic BGP Routing Demo" 
#video. 

#Ensure that you run this script and patch the AWS VPN Vyatta config file
#before continuing on with the remainder of the applied VYOS config
#**********************
#**********************

#Updates lines 98 and 189
#set protocols bgp 65000 neighbor 169.254.***.*** soft-reconfiguration 'inbound'
#becomes:
#set protocols bgp 65000 neighbor 169.254.***.*** address-family ipv4-unicast soft-reconfiguration inbound

sed -i .bak1 "s/soft-reconfiguration 'inbound'/address-family ipv4-unicast soft-reconfiguration inbound/g" $VPN_VYATTA_TXT_FILE

#=====================================

#Updates lines 106 and 197
#set protocols bgp 65000 network 0.0.0.0/0
#becomes
#set protocols bgp 65000 address-family ipv4-unicast network 0.0.0.0/0

sed -i .bak2 "s/set protocols bgp 65000 network 0.0.0.0\/0/set protocols bgp 65000 address-family ipv4-unicast network 0.0.0.0\/0/g" $VPN_VYATTA_TXT_FILE

echo finished!