#!/bin/sh

#
# Pre-req
# 1. The Ubuntu VM must exist for this HAProxy to install
# 2. Execute this on the Ubuntu HAProxy VM
# 
apt-get update

#Install stable release of HAProxy1.8 and it should run automatically by default
apt-get install -y haproxy=1.8.\*

 
