class onos::config{
$onos_home = $onos::onos_home
$karaf_dist = $onos::karaf_dist
$onos_boot_features = $onos::onos_boot_features
$onos_extra_features = $onos::onos_extra_features
$roles =  $onos::roles
$public_vip = hiera('public_vip')
$management_vip = hiera('management_vip')
$controllers_names = $onos::controllers_names
$controllers_ip = $onos::controllers_ip
$onos_pkg_name = $onos::onos_pkg_name
$jdk8_pkg_name = $onos::jdk8_pkg_name

Haproxy::Service        { use_include => true }
Haproxy::Balancermember { use_include => true }
  
Exec{
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        timeout => 180,
        logoutput => "true",
}

file{ '/opt/onos_config.sh':
        source => "puppet:///modules/onos/onos_config.sh",
} ->
exec{ 'install onos config':
        command => "sh /opt/onos_config.sh;
	rm -rf /opt/onos_config.sh;",
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
}->
exec{ "clean used files":
        command => "rm -rf /opt/$onos_pkg_name;
        rm -rf /opt/$jdk8_pkg_name
        rm -rf /root/.m2/*.tar"
}->
exec{ 'onos boot features':
        command => "sed -i '/^featuresBoot=/c\featuresBoot=$onos_boot_features' $onos_home/$karaf_dist/etc/org.apache.karaf.features.cfg",
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
}->
file{ "${onos_home}/config/cluster.json":

        ensure => file,
        content => template('onos/cluster.json.erb')
}

file{ "${onos_home}/config/tablets.json":
        ensure => file,
        content => template('onos/tablets.json.erb'),
}
case $::operatingsystem {
   ubuntu:{
        file{'/etc/init/onos.conf':
        ensure => file,
        content => template('onos/debian/onos.conf.erb')
}}
    centos:{
        file{'/etc/init.d/onos':
        ensure => file,
        content => template('onos/centos/onos.erb'),
	mode => 0777
	
}

}
}


if !member($roles, 'compute') {
haproxy::listen { 'onos':
    order => '221',
    ipaddress => [$public_vip,$management_vip],
    ports     => '8181',
    options   => {'balance' => 'source','option' => ['httpchk /onos/ui','httplog'], 'timeout client' => '2h','timeout server' => '2h'}, 
    mode      => 'http',
 }

haproxy::balancermember { 'onos':
    order => '221',
    listening_service => 'onos',
    ports             => '8181',
    server_names      => $controllers_names,
    ipaddresses       => $controllers_ip,
    options           => 'check inter 2000 rise 2 fall 5',
    define_cookies    => 'true'
  }
}
}
