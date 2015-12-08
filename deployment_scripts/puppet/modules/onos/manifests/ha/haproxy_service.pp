define onos::ha::haproxy_service (
  $order,
  $server_names,
  $ipaddresses,
  $listen_port,
  $public_virtual_ip,
  $internal_virtual_ip,

  $mode                   = undef,
  $haproxy_config_options = { 'option' => ['httplog'], 'balance' => 'roundrobin' },
  $balancermember_options = 'check',
  $balancermember_port    = $listen_port,
  $define_cookies         = false,
  $define_backups         = false,
  $public                 = false,
  $internal               = true,
  $require_service        = undef,
  $before_start           = false,
) {

  $virtual_ips = [$public_virtual_ip, $internal_virtual_ip]

  haproxy::listen { $name:
    order     => $order,
    ipaddress => $virtual_ips,
    ports     => $listen_port,
    options   => $haproxy_config_options,
    mode      => $mode,
  }

  haproxy::balancermember { $name:
    order             => $order,
    listening_service => $name,
    server_names      => $server_names,
    ipaddresses       => $ipaddresses,
    ports             => $balancermember_port,
    options           => $balancermember_options,
    define_cookies    => $define_cookies,
    define_backups    => $define_backups,
  }

  if $require_service {
    Service[$require_service] -> Haproxy::Listen[$name]
    Service[$require_service] -> Haproxy::Balancermember[$name]
  }
}

