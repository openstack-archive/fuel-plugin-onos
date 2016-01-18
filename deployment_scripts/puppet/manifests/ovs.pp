include onos


Exec{path => "/usr/bin:/usr/sbin:/bin:/sbin",}

case $::operatingsystem{
centos:{
	$neutron_ovs_agent='neutron-openvswitch-agent'
	$ovs_service='openvswitch'
	$cmd_remove_agent='chkconfig --del neutron-openvswitch-agent'
}
ubuntu:{
	$neutron_ovs_agent='neutron-plugin-openvswitch-agent'
	$ovs_service='openvswitch-switch'
	$cmd_remove_agent='update-rc.d neutron-plugin-openvswitch-agent remove'
}

}

$roles =  $onos::roles

if member($roles, 'primary-controller') {
cs_resource { "p_${neutron_ovs_agent}":
    ensure => absent,
    before => Service["shut down and disable Neutron's agent services"],
}
}
else{
exec{'remove neutron-openvswitch-agent auto start':
        command => "touch /opt/service;
        $cmd_remove_agent;
        sed -i /neutron-openvswitch-agent/d /opt/service",
        before => Service["shut down and disable Neutron's agent services"],
}
}


firewall{'222 vxlan':
      port   => [4789],
      proto  => 'udp',
      action => 'accept',
}->
service {"shut down and disable Neutron's agent services":
		name => $neutron_ovs_agent,
		ensure => stopped,
		enable => false,
}->
exec{'Stop the OpenvSwitch service and clear existing OVSDB':
        command =>  "service $ovs_service stop ;
        rm -rf /var/log/openvswitch/* ;
        rm -rf /etc/openvswitch/conf.db ;
        service $ovs_service start ;"

} ->
exec{'Set ONOS as the manager':
        command => "su -s /bin/sh -c 'ovs-vsctl set-manager tcp:${onos::manager_ip}:6640'",

}


$public_eth = $onos::public_eth
if member($roles, 'compute') {
exec{"net config":
        command => "ifconfig $public_eth up",
}
}
else
{
exec{"sleep 20 for ovsconnect":
        command => "sleep 20",
        require => Exec['Set ONOS as the manager'],
}->
exec{"delete public port from ovs of controllers":
        command => "ovs-vsctl del-port br-int $public_eth",
}->

service {'stop neutron service':
         name => "neutron-server",
         ensure => stopped
}->
neutron_config { 'DEFAULT/service_plugins':
        value => 'onos_router,neutron.services.metering.metering_plugin.MeteringPlugin';
}->


neutron_plugin_ml2 {
  'ml2/mechanism_drivers':       value => 'onos_ml2';
  'ml2/tenant_network_types':    value => 'vxlan';
  'ml2_type_vxlan/vni_ranges':   value => '100:50000';
  'onos/password':           value => 'admin';
  'onos/username':           value => 'admin';
  'onos/url_path':           value => "http://${onos::manager_ip}:8181/onos/vtn";
}
}


