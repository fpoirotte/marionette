class pbuilder {
	file {
	"/etc/skel/.pbuilderrc":
		ensure => present,
		source => "puppet:///modules/pbuilder/pbuilderrc",
	}

	file {
	"/root/.pbuilderrc":
		source => "/etc/skel/.pbuilderrc",
		mode => 0600,
		owner => root,
		group => root,
	}

	define cowbuilder($id = $name, $distro, $arch) {
		$cache = "/var/cache/pbuilder"
		exec {
		"cowbuilder_${id}":
			command => "cowbuilder --create --architecture $arch --distribution $distro --basepath ${cache}/base-${distro}_${arch}.cow",
			require => Package['cowbuilder'],
			creates => "${cache}/base-${distro}_${arch}.cow",
		}
		cron {
		"pbuilder_${id}":
			command => "/usr/sbin/cowbuilder --update --architecture $arch --distribution $distro --basepath ${cache}/base-${distro}_${arch}.cow 2>&1 > /dev/null | /bin/grep -v '^I:'",
			require => Exec["cowbuilder_${id}"],
			environment => 'PATH=/bin:/sbin:/usr/bin:/usr/sbin',
			user => root,
			hour => '6',
			minute => '0',
		}
	}

	cowbuilder {
	amd64_jessie:
		distro => jessie,
		arch => amd64;
	i386_jessie:
		distro => jessie,
		arch => i386;
	amd64_wheezy:
		distro => wheezy,
		arch => amd64;
	i386_wheezy:
		distro => wheezy,
		arch => i386;
	}
}
