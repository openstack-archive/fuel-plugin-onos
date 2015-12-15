class onos{
$nodes = hiera('nodes')
$primary_controller = filter_nodes($nodes,'role','primary-controller')
$roles = node_roles($nodes, hiera('uid'))

#$onos_settings = hiera('onos')
$onos_hash = filter_nodes($nodes,'role','onos')
$manager_ip = filter_hash($onos_hash, 'internal_address')
$onos_names = filter_hash($onos_hash, 'name')

$onos_home = '/opt/onos'
$onos_pkg_url = 'http://downloads.onosproject.org/release/onos-1.3.0.tar.gz'
$karaf_dist = 'apache-karaf-3.0.3'
$onos_pkg_name = 'onos-1.3.0.tar.gz'
$jdk8_pkg_name = 'jdk-8u51-linux-x64.tar.gz'
$onos_boot_features = 'config,standard,region,package,kar,ssh,management,webconsole,onos-api,onos-core,onos-incubator,onos-cli,onos-rest,onos-gui,onos-openflow-base,onos-openflow'
$onos_extra_features = 'ovsdb,vtnrsc,vtnweb,vtn,proxyarp'
}
