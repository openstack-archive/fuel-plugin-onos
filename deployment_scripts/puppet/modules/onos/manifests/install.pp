
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
file{ '/opt/networking-onos.tar':
        source =>"puppet:///modules/onos/networking-onos.tar",
} ->
file{ "/opt/$jdk8_pkg_name":
        source => "puppet:///modules/onos/$jdk8_pkg_name",
} ->
file{ '/opt/install_jdk8.tar':
        source => "puppet:///modules/onos/install_jdk8.tar",
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
        tar vxf /opt/networking-onos.tar -C /opt;
        tar xf /opt/install_jdk8.tar -C /opt;
        tar xf /root/.m2/repository.tar -C /root/.m2/",
} ->
exec{ "install driver and jdk":
        command => "sh /opt/networking-onos/install_driver.sh;
        sh /opt/install_jdk8/install_jdk8.sh",
} ->
exec{ "clean used files":
        command => "rm -rf /opt/*.tar*;
        rm -rf /opt/install_jdk8;
        rm -rf /opt/networking-onos;
        rm -rf /root/.m2/*.tar"
}
}
