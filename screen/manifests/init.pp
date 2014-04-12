class screen {
	file {
	"/etc/screenrc":
		ensure => present,
		source => "puppet:///modules/screen/screenrc",
	}
}
