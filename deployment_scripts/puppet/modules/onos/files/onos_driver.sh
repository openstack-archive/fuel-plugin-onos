#!/bin/bash

set -eux

cd /opt
#git clone https://github.com/openstack/networking-onos.git
tar xf networking-onos.tar
cd networking-onos
python setup.py install

