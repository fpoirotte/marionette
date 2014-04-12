class apt {
	file {
	"/etc/apt/sources.list":
		source => "puppet:///modules/apt/sources.list",
		notify => Exec['aptitude update'],
	}

	file {
	"/etc/apt/apt.conf.d/recommends":
		source => "puppet:///modules/apt/apt.conf.d/recommends",
	}

	file {
	"/etc/apt/apt.conf.d/10periodic":
		source => "puppet:///modules/apt/apt.conf.d/10periodic",
	}

	file {
	"/etc/apt/preferences":
		source => "puppet:///modules/apt/preferences",
		notify => Exec['aptitude update'],
	}

	exec {
	"multiarch-i386":
		command => "/usr/bin/dpkg --add-architecture i386",
		unless => "/usr/bin/dpkg --printf-architecture | grep '^i386\$'",
	}

	define apt_source($url = undef, $key = undef) {
		file {
		"/etc/apt/sources.list.d/${name}":
			source => "puppet:///modules/apt/sources.list.d/${name}",
			notify => Exec['aptitude update'],
		}
		if $url != undef {
			exec {
			"apt_source-$name":
				command => "/usr/bin/wget -q ${url} -O- | /usr/bin/apt-key add -",
				unless => "/usr/bin/apt-key adv --list-key ${key}",
			}
		}
	}

	apt_source {
	"deb-multimedia.list": ;
	#"grsecurity.list": key => 'http://www.corsac.net/71ef0ba8.asc';
	"puppetlabs.list":
		url => 'http://apt.puppetlabs.com/pubkey.gpg',
		key => '4BD6EC30',
	;
	}

	exec {
	"aptitude update":
		require => Package['aptitude'],
	}
}
