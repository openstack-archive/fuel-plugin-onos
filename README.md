#ONOS Plugin for Fuel#

##Brief##

This plugin will install [ Open Network Operating System (ONOS) controller](https://wiki.onosproject.org/display/ONOS/Wiki+Home), which is a typical SDN controller, and set it as a manager of ovs.


##Notification##


* Fuel opentack version should be after 7.0.
* Only supports the environment with network type: Neutron.
* Live migration is supported.
* L2 and L3 traffic are supported.


##Installation Guide##


###ONOS plugin installation###


1. Log in Fuel Master and clone GIT repository of fuel-plugin-onos from openstack:

        git clone -b kilo git://git.openstack.org/openstack/fuel-plugin-onos

2. Preparing an environment for plugin development by three easy steps:

    A. Install the standard Linux development tools.

    For Ubuntu 14.04 LTS, run:

        sudo apt-get install createrepo rpm dpkg-dev
    For Centos 6.5, run:

        yum install createrepo rpm rpm-build dpkg-devel

    B. Install the Fuel Plugin Builder. To do that, you should first get pip:

        easy_install pip

     C. Then, install Fuel Plugin Builder (fpb) itself:


        pip install fuel-plugin-builder

3. Build ONOS plugin for fuel:

        fpb --build fuel-plugin-onos/

4. The onos rpm will be built in the folder of fuel-plugin-onos.

5. Install the onos plugin:

        fuel plugins --install onos*.rpm

6. Check if you successfully install the plugin:

        fuel plugins

        id | name   | version | package_version
        ---|--------|---------|----------------
        1  | onos   | 0.7.0   | 3.0.0

     
7. Check if the plugin is enabled on the settings table.

Notice: Step 1-4 aren't limitted with the environment of master, you can also make it everywhere, but after the rpm is made, you should copy it to the master. In addition, the info of a new plugin at settings table can only be ready  when a new environment is created.


##User Guide##


###ONOS plugin configuration###


All described actions below are described from a Fuel GUI provisioning perspective.

1. Create a new environment.

2. Select 'onos plugin' on Settings tab.

     onos plugin

3. Select three nodes with role 'controller', three with role 'compute' and one with 'onos'.

4. Click 'Deploy changes' to enable nodes with ONOSFW.



###Dependencies###

In order to run ONOS, the following are required:

- Java 8 JDK (Oracle Java recommended; OpenJDK is not as thoroughly tested)
- ONOS tarball( Newest version 1.3 recommended.)

Notice: In case of version problems, the onos rpm uses jdk and onos packages that have been tested.

###Testing###

1. Web UI is recommended for ONOS controller with tuitive information of topo, devices and etc.
For that purpose, IP address of horizon should be ready, which can be found in fuel master after successful deployment. The web will run into the log page after inputing the path, username and password are both 'karaf'. Now enjot ONOS!

        Web UI: http://horizon_ip:8181/onos/ui/index.html
2. CLI is capable of more diverse functionality by running /opt/onos/bin/onos. More about CLI can be found in [The ONOS CLI](
https://wiki.onosproject.org/display/ONOS/The+ONOS+CLI).


##Getting Involved##

Interested in contributing? Follow [Fuel Plugins Development](
https://wiki.openstack.org/wiki/Fuel/Plugins).

##Contributors##

1.       Wu Wenbin <wuwenbin2@huawei.com>
2.       Zhang Haoyu <zhanghaoyu7@huawei.com>

