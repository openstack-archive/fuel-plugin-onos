#!/bin/bash

set -eux

#apt-get -y install git
cd /opt
git clone https://github.com/openstack/networking-onos.git
cd networking-onos
python setup.py install
