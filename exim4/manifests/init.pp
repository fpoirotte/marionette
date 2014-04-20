class exim4 {
	file {
	"/etc/exim4/passwd.client":
		source => 'puppet:///modules/exim4/passwd.client',
		mode => 0640,
		owner => root,
		group => 'Debian-exim',
	}
}
