class onos::ha::haproxy {


  Haproxy::Service        { use_include => true }
  Haproxy::Balancermember { use_include => true }

  $public_vip = hiera('public_vip')
  $management_vip = hiera('management_vip')
  $nodes_hash = hiera('nodes')
  $primary_controller_nodes = filter_nodes($nodes_hash,'role','primary-controller')
  $onos_controllers = filter_nodes($nodes_hash,'role','onos')

  Openstack::Ha::Haproxy_service {
      internal_virtual_ip => $management_vip,
      ipaddresses         => filter_hash($onos_controllers, 'internal_address'),
      public_virtual_ip   => $public_vip,
      server_names        => filter_hash($onos_controllers, 'name'),
      public              => true,
      internal            => true,
  }

  openstack::ha::haproxy_service { 'onos':
    order                  => '221',
    listen_port            => '8181',
    haproxy_config_options => {
      'option'         => ['httpchk /onos/ui', 'httplog'],
      'timeout client' => '2h',
      'timeout server' => '2h',
      'balance'        => 'source',
      'mode'           => 'http'
    },
    balancermember_options => 'check inter 2000 fall 5',
  }
  
  exec { 'haproxy reload':
    command   => 'export OCF_ROOT="/usr/lib/ocf"; (ip netns list | grep haproxy) && ip netns exec haproxy /usr/lib/ocf/resource.d/fuel/ns_haproxy reload',
    path      => '/usr/bin:/usr/sbin:/bin:/sbin',
    logoutput => true,
    provider  => 'shell',
    tries     => 10,
    try_sleep => 10,
    returns   => [0, ''],
  }

  Haproxy::Listen <||> -> Exec['haproxy reload']
  Haproxy::Balancermember <||> -> Exec['haproxy reload']
}

