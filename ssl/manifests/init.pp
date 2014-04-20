class ssl {
	file {
	"/etc/ssl/openssl.cnf":
		source => "puppet:///modules/ssl/openssl.cnf",
	}
}
