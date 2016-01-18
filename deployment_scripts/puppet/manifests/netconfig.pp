include onos

Exec{
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        timeout => 180,
        logoutput => "true",
}

$neutron_settings = hiera_hash('quantum_settings')
$nets = $neutron_settings['predefined_networks']
$gateway_ip = $nets['net04_ext']['L3']['gateway']
$public_eth = $onos::public_eth

file{ "/opt/netconfig.sh":
        ensure => file,
        content => template('onos/netconfig.sh.erb'),
}->
exec{ 'set gatewaymac':
        command => "sh /opt/netconfig.sh;
        rm -rf /opt/netconfig.sh;",
}
