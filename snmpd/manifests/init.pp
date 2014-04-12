class snmpd {
	file {
	"/etc/snmp/snmpd.conf":
		ensure => present,
		mode => 0600,
		source => "puppet:///modules/snmpd/snmpd.conf",
		require => Package['snmpd'],
	}

	file {
	"/etc/default/snmpd":
		ensure => present,
		source => "puppet:///modules/snmpd/initconf",
		require => Package['snmpd'],
	}
}
