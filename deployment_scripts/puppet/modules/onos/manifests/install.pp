
class onos::install{
$onos_home = $onos::onos_home
$onos_pkg_url = $onos::onos_pkg_url
$karaf_dist = $onos::karaf_dist
$onos_pkg_name = $onos::onos_pkg_name
$jdk8_pkg_name = $onos::jdk8_pkg_name


Exec{
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
	logoutput => "true",
        timeout => 180,
}
group { 'onos':
      ensure => present,
      before => [File['/opt/onos/'], User['onos']],
    }


user { 'onos':
      ensure     => present,
      home       => '/opt/onos/',
      membership => 'minimum',
      groups     => 'onos',
      before     => File['/opt/onos/'],
    }


file { '/opt/onos/':
        ensure  => 'directory',
        recurse => true,
        owner   => 'onos',
        group   => 'onos',
}->


file{ "/opt/$onos_pkg_name":
        source => "puppet:///modules/onos/$onos_pkg_name",
} ->
file{ "/opt/$jdk8_pkg_name":
        source => "puppet:///modules/onos/$jdk8_pkg_name",
} ->

file{ '/root/.m2/':
        ensure => 'directory',
        recurse => true,
} ->
file{ '/root/.m2/repository.tar':
        source => "puppet:///modules/onos/repository.tar",
} ->
exec{ "unzip packages":
        command => "tar -zvxf /opt/$onos_pkg_name -C $onos_home  --strip-components 1 --no-overwrite-dir -k;
        tar xf /root/.m2/repository.tar -C /root/.m2/",
}
}
