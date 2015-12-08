include onos

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }


package { 'install git':
  ensure => installed,
  name   => "git",
}->

file{ '/opt/onos_driver.sh':
        source => "puppet:///modules/onos/onos_driver.sh",
} ->
exec{ 'install onos driver':
        command => "sh /opt/onos_driver.sh;"
}->

cs_resource { 'p_neutron-l3-agent':
      ensure => absent,
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
}->

exec{ 'delete Neutron db':
        command  => "mysql -e 'drop database if exists neutron;';
		    mysql -e 'create database neutron character set utf8;';
		    mysql -e \"grant all on neutron.* to 'neutron'@'%';\";
		    neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head;",
} ->
service {"start neutron service":
         name => "neutron-server",
         ensure => running
}


