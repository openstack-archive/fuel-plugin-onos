class onos{
$nodes = hiera('nodes')
$primary_controller = filter_nodes($nodes,'role','primary-controller')
$manager_ip = $primary_controller[0]['internal_address']
$roles = node_roles($nodes, hiera('uid'))
$controllers = concat($primary_controller, filter_nodes($nodes,'role','controller'))
$controllers_ip = filter_hash($controllers, 'internal_address')
$controllers_names = filter_hash($controllers, 'name')
$onos_home = '/opt/onos'
$onos_pkg_url = 'http://downloads.onosproject.org/release/onos-1.3.0.tar.gz'
$karaf_dist = 'apache-karaf-3.0.3'
$onos_pkg_name = 'onos-1.3.0.tar.gz'
$jdk8_pkg_name = 'jdk-8u51-linux-x64.tar.gz'
$onos_boot_features = 'config,standard,region,package,kar,ssh,management,webconsole,onos-api,onos-core,onos-incubator,onos-cli,onos-rest,onos-gui,onos-openflow'
$onos_extra_features = 'ovsdb,vtnrsc,vtnweb,vtn,proxyarp'
}
