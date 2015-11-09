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
}

