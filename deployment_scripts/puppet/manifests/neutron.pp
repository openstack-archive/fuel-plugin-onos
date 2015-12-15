include onos

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }
$net04_ext =
    {"shared"=>false,
     "L2"=>
      {"network_type"=>"vxlan",
       "router_ext"=>true,
       "segment_id"=>"10000"},
     "L3"=>
      {"nameservers"=>[],
       "subnet"=>"172.16.0.0/24",
       "floating"=>"172.16.0.50:172.16.0.253",
       "gateway"=>"172.16.0.1",
       "enable_dhcp"=>false},
     "tenant"=>"admin"}
$net04 =
    {"shared"=>false,
     "L2"=>
      {"network_type"=>"vxlan",
       "router_ext"=>false,
       "segment_id"=>"500"},
     "L3"=>
      {"nameservers"=>["114.114.114.114", "8.8.8.8","8.8.4.4"],
       "subnet"=>"192.168.111.0/24",
       "gateway"=>"192.168.111.1",
       "enable_dhcp"=>true},
     "tenant"=>"admin"}

$network_type = 'vxlan'
$roles =  $onos::roles

if member($roles, 'primary-controller') {
cs_resource { 'p_neutron-l3-agent':
      ensure => absent,
      before => Service ["start neutron service"],
}
}

package { 'install git':
  ensure => installed,
  name   => "git",
}->

file{ "/opt/networking-onos.tar":
        source => "puppet:///modules/onos/networking-onos.tar",
}->
file{ '/opt/onos_driver.sh':
        source => "puppet:///modules/onos/onos_driver.sh",
} ->
exec{ 'install onos driver':
        command => "sh /opt/onos_driver.sh;"
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
}->
openstack::network::create_network{'net04':
    netdata => $net04,
    segmentation_type => $network_type,
} ->
  openstack::network::create_network{'net04_ext':
    netdata => $net04_ext,
    segmentation_type => $network_type,
}-> 
openstack::network::create_router{'router04':
    internal_network => 'net04',
    external_network => 'net04_ext',
    tenant_name      => 'admin',
}



