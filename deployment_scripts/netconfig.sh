#!/bin/bash

set -eux
ifconfig eth3 172.16.0.254/24 up
route add default gw 172.16.0.1
ping -c 2 172.16.0.1
gatewayMac=`arp -a 172.16.0.1 | awk '{print $4}'`
/opt/onos/bin/onos "externalgateway-update -m $gatewayMac"
