include onos

$neutron_ovs_agent = $::operatingsystem ? {
  'CentOS' => 'neutron-openvswitch-agent',
  'Ubuntu' => 'neutron-plugin-openvswitch-agent',
}

$ovs_service = $::operatingsystem ? {
  'CentOS' => 'openvswitch',
  'Ubuntu' => 'openvswitch-switch',
}

Exec{path => "/usr/bin:/usr/sbin:/bin:/sbin",}

$cmd_remove_agent = $operatingsystem ? {
  'CentOS' => 'chkconfig --del neutron-openvswitch-agent',
  'Ubuntu' => 'update-rc.d neutron-plugin-openvswitch-agent remove',
}
firewall{'222 vxlan':
      port   => [4789],
      proto  => 'udp',
      action => 'accept',
}->
exec{'remove neutron-plugin-openvswitch-agent auto start':
        command => "touch /opt/service;
        $cmd_remove_agent;
        sed -i /neutron-openvswitch-agent/d /opt/service",
} ->
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
        command => "su -s /bin/sh -c 'ovs-vsctl set-manager tcp:${onos::ovs_manager_ip}:6640'",

}


