
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
exec{ 'add onos auto start':
        command => 'echo "onos">>/opt/service',
}
}
