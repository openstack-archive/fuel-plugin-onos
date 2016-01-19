include onos

Exec { path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ] }

$neutron_config = hiera_hash('quantum_settings')
$nets = $neutron_config['predefined_networks']
$net04_ext =
    {"shared"=>false,
     "L2"=>
      {"network_type"=>"vxlan",
       "router_ext"=>true,
       "segment_id"=>"10000"},
     "L3"=> $nets['net04_ext']['L3'],
     "tenant"=>"admin"}
$net04 =
    {"shared"=>false,
     "L2"=>
      {"network_type"=>"vxlan",
       "router_ext"=>false,
       "segment_id"=>"500"},
     "L3"=> $nets['net04']['L3'],
      "tenant"=>"admin"}
$roles =  $onos::roles
$network_type = 'vxlan'

if member($roles, 'primary-controller') {
cs_resource { 'p_neutron-l3-agent':
      ensure => absent,
}->
exec { 'drop_neutron_db':
  command => "mysql -e 'drop database if exists neutron;'",
}->

exec { 'create_neutron_db':
  command => "mysql -e 'create database neutron character set utf8;'",
}->

exec { 'grant_neutron_db':
  command => "mysql -e \"grant all on neutron.* to 'neutron'@'%';\"",
}->

exec { 'neutron_db_sync':
  command => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade head',
  before => Service ['start neutron service'],
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


service {'start neutron service':
         name => "neutron-server",
         ensure => running
}



if member($roles, 'primary-controller') {

    Service<| title == 'start neutron service' |> ->
      Openstack::Network::Create_network <||>

    Service<| title == 'start neutron service' |> ->
      Openstack::Network::Create_router <||>

openstack::network::create_network{'net04':
    netdata => $net04,
    segmentation_type => $network_type,
} ->
  openstack::network::create_network{'net04_ext':
    netdata => $net04_ext,
    segmentation_type => $network_type,
} ->
  openstack::network::create_router{'router04':
    internal_network => 'net04',
    external_network => 'net04_ext',
    tenant_name      => 'admin',
}
}
