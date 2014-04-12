class grub {
	$kernel = "linux-image-2.6.32-5-grsec-amd64"

	package {
	$kernel:
		ensure => present,
	}

	file {
	"/etc/grub.d/06_OVHkernel":
		ensure => absent,
	}

	file {
	"/etc/sysctl.d/grsec.conf":
		ensure => present,
		source => "puppet:///modules/grub/grsec.conf",
		require => Package[$kernel],
	}

	exec {
	"/sbin/sysctl -p":
		require => File['/etc/sysctl.d/grsec.conf'],
		refreshonly => true,
	}

	exec {
	"/usr/sbin/update-grub2":
		require => [
			Package[$kernel],
			File['/etc/grub.d/06_OVHkernel'],
		],
		refreshonly => true,
	}
}
