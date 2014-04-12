class services {
	Service {
		ensure => running,
		enable => true,
		hasrestart => true,
		hasstatus => true,
	}

	service {
	buildmaster:
		ensure => $fqdn ? {
			"sd-19900.dedibox.fr"	=> running,
			"erebot.net"		=> running,
			default			=> stopped,
		},
		hasstatus => false,
		require => File['/etc/default/buildmaster'],
		status => "ps aux | grep -e `cat /home/qa/master/twistd.pid` | grep /usr/bin/buildbot",
	}

	service {
	buildslave:
		hasstatus => false,
		require => File['/etc/default/buildslave'],
		status => "ps aux | grep -e `cat /home/qa/slave/twistd.pid` | grep /usr/bin/buildslave",
	}

	service {
	cron:
		require => Package['cron'],
	}

	service {
	"libvirt-bin":
		require => Package["libvirt-bin/wheezy-backports"],
	}

	service {
	mysql:
		require => Package['mysql-server'],
	}

	service {
	nginx:
		require => Package["nginx"],
	}

	service {
	openvpn:
		subscribe => File['/etc/openvpn/erebot.conf'],
		require => [
			Package["openvpn/wheezy-backports"],
			Package['ca-certificates'],
		],
	}

	service {
	"php-fpm":
		require => File['/etc/init.d/php-fpm'],
	}

	service {
	"qemu-system-x86":
		require => Package["qemu-kvm/wheezy-backports"],
		hasstatus => false,
	}

	service {
	snmpd:
		hasstatus => false,
		subscribe => [
			File['/etc/default/snmpd'],
			File['/etc/snmp/snmpd.conf'],
		],
		require => [
			Package['snmpd'],
		],
	}

	service {
	ssh:
		subscribe => File['/etc/ssh/sshd_config'],
		require => Package['openssh-server'],
	}

	service {
	"ids.erebot.net":
		require => File[
			'/etc/init.d/ids.erebot.net',
			'/etc/default/prewikka-httpd'
		],
	}

	service {
	"www.erebot.net":
		require => File['/etc/init.d/www.erebot.net'],
	}

	service {
	"prelude-lml":
		require => File['/etc/prelude-lml/prelude-lml.conf'],
	}
}
