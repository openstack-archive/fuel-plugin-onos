
class onos::service{


Exec{
        path => "/usr/bin:/usr/sbin:/bin:/sbin",
        timeout => 320,
	logoutput => 'true',
}

firewall {'221 onos':
      port   => [6633, 6640, 6653, 8181, 8101,9876],
      proto  => 'tcp',
      action => 'accept',
}->
service{ 'onos':
        ensure => running,
        enable => true,
        hasstatus => true,
        hasrestart => true,
}->

exec{ 'sleep 100 to stablize onos':
        command => 'sleep 100;'
}->

exec{ 'restart onos':
        command => 'service onos restart',
}->

exec{ 'sleep 100 again to stablize onos':
        command => 'sleep 100;'
}->
exec{ 'restart onos again':
        command => 'service onos restart',
}->

exec{ 'sleep 60 to stablize onos':
        command => 'sleep 60;'
}->

exec{ 'add onos auto start':
        command => 'echo "onos">>/opt/service',
}->
exec{ 'set public port':
        command => "/opt/onos/bin/onos \"externalportname-set -n eth3\""
}
}
