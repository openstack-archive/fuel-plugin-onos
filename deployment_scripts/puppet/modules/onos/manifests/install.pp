
class onos::install{
$onos_home = $onos::onos_home
$onos_pkg_url = $onos::onos_pkg_url
$karaf_dist = $onos::karaf_dist
$onos_pkg_name = $onos::onos_pkg_name
$jdk8_pkg_name = $onos::jdk8_pkg_name


Exec{
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        timeout => 180,
}


file{ "/opt/$onos_pkg_name":
        source => "puppet:///modules/onos/$onos_pkg_name",
} ->
file{ '/opt/mechanism_onos.py':
        source =>"puppet:///modules/onos/mechanism_onos.py",
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
