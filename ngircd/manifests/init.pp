class ngircd {
	$oper_login = extlookup('irc_oper_login')
	$oper_pass  = extlookup('irc_oper_pass')

	service {
	"ngircd":
		require => File['/etc/ngircd/ngircd.conf'],
	}

	package {
	"ngircd":
	}

	file {
	"/etc/ngircd/ngircd.conf":
		content => template('ngircd/ngircd.conf'),
		require => [
			Package["ngircd"],
			File['/etc/openvpn/cacert/dh2048.pem'],
			File['/etc/ngircd/irc.erebot.net.pem'],
			File['/etc/ngircd/irc.erebot.net.key'],
		],
		notify => Service['ngircd'],
	}

	file {
	"/etc/ngircd/irc.erebot.net.pem":
		source => 'puppet:///modules/ngircd/ssl/irc.erebot.net.pem',
		notify => Service['ngircd'],
	}

	file {
	"/etc/ngircd/irc.erebot.net.key":
		source => 'puppet:///modules/ngircd/ssl/irc.erebot.net.key',
		notify => Service['ngircd'],
		mode => 0600,
		owner => root,
		group => root,
	}
}
