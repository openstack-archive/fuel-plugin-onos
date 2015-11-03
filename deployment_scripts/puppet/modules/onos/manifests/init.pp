class onos{
$nodes_hash = hiera('nodes')
$primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
$ovs_manager_ip = $primary_controller_nodes[0]['internal_address']

$controllers = concat($primary_controller_nodes, filter_nodes($nodes_hash,'role','controller'))
$controllers_ip = filter_hash($controllers, 'internal_address')

$onos_home = '/opt/onos'
$onos_pkg_url = 'http://downloads.onosproject.org/release/onos-1.3.0.tar.gz'
$karaf_dist = 'apache-karaf-3.0.3'
$onos_pkg_name = 'onos-1.3.0.tar.gz'
$jdk8_pkg_name = 'jdk-8u51-linux-x64.tar.gz'
$onos_boot_features = 'config,standard,region,package,kar,ssh,management,webconsole,onos-api,onos-core,onos-incubator,onos-cli,onos-rest,onos-gui,onos-openflow'
$onos_extra_features = 'ovsdb,vtnrsc,vtn,vtnweb,proxyarp'
}
