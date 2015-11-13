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
service {'neutron-server':
          ensure => stopped,
          enable => false,
}->
cs_resource { "p_${neutron_ovs_agent}":
    ensure => absent,
    before => Service["shut down and disable Neutron's agent services"],
  }}
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




