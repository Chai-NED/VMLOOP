#!/bin/sh

#
# Pre-req
# 1. The Ubuntu VM must exist for this HAProxy to install
# 2. Execute this on the Ubuntu HAProxy VM
# 
apt-get update

#Install stable release of HAProxy1.8
apt-get install -y haproxy=1.8.\*

 # Enable haproxy (to be started during boot)
tmpf=`mktemp` && mv /etc/default/haproxy $tmpf && sed -e "s/ENABLED=0/ENABLED=1/" $tmpf > /etc/default/haproxy && chmod --reference $tmpf /etc/default/haproxy


# Start the proxy servie
 service haproxy start

