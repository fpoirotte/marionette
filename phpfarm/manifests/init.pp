class phpfarm {
	$main_version = '5.4.27-debug'

	Exec {
		user => qa,
		group => qa,
	}

	file {
	[
		"/home/qa/config",
		"/home/qa/config/buildenv",
		"/home/qa/config/buildenv/git",
	]:
		ensure => directory,
		mode => 0755,
		owner => qa,
		group => qa,
	}

	define config_git {
		if $name =~ /\/([^\/]+)\.git$/ {
			$shortname = $1
			exec {
			"clone-$shortname":
				command => "/usr/bin/git clone $name",
				cwd => '/home/qa/config/buildenv/git',
				unless => "/usr/bin/test -d /home/qa/config/buildenv/git/$shortname",
				require => File['/home/qa/config/buildenv/git'],
			}
		}
	}

	config_git {[
		'git://github.com/pear2/Autoload.git',
		'git://github.com/fpoirotte/Pirum.git',
		'git://github.com/pyrus/Pyrus.git',
		'git://github.com/pyrus/Pyrus_Developer.git',
	]:}

	exec {
	"phpfarm-install-custom":
		command => '/usr/bin/git clone git://github.com/Erebot/Erebot_farm.git',
		cwd => '/home/qa/config',
		unless => "/usr/bin/test -d /home/qa/config/Erebot_farm",
		require => [
			Package["git"], 
			File['/home/qa/config'],
		],
		notify => Exec['phpfarm'],
	}

	exec {
	"phpfarm-update-custom":
		command => '/usr/bin/git pull',
		cwd => '/home/qa/config/Erebot_farm',
		onlyif => '/usr/bin/git remote update 2>&1 | /bin/grep -e "->"',
		require => Exec['phpfarm-install-custom'],
		notify => Exec['phpfarm'],
	}

	exec {
	"phpfarm-install":
		command => '/usr/bin/git clone git://github.com/fpoirotte/phpfarm.git',
		cwd => '/home/qa/',
		unless => "/usr/bin/test -d /home/qa/phpfarm",
		require => Package["git"], 
		notify => Exec['phpfarm'],
	}

	exec {
	"phpfarm-update":
		command => '/usr/bin/git pull',
		cwd => '/home/qa/phpfarm',
		onlyif => '/usr/bin/git remote update 2>&1 | /bin/grep -e "->"',
		require => Exec['phpfarm-install'],
		notify => Exec['phpfarm'],
	}

	file {
	"/home/qa/phpfarm/custom":
		ensure => link,
		target => '/home/qa/config/Erebot_farm/',
		require => [
			Exec['phpfarm-update'],
			Exec['phpfarm-update-custom'],
		]
	}

	file {
	"/home/qa/phpfarm/src/bzips/pyrus.phar":
		ensure => link,
		target => '/home/qa/config/buildenv/git/Pyrus/scripts/pyrus',
		require => [
			Exec['phpfarm-update'],
			Exec['clone-Pyrus'],
			Exec['clone-Pyrus_Developer'],
		],
	}

	exec {
	"get-pear-installer":
		command => "/usr/bin/curl --remote-name http://pear.php.net/install-pear-nozlib.phar",
		cwd => '/home/qa/phpfarm/src/bzips',
		creates => '/home/qa/phpfarm/src/bzips/install-pear-nozlib.phar',
		require => Exec['phpfarm-update'],
	}

	exec {
	"phpfarm":
		command => "/home/qa/phpfarm/src/main.sh $main_version",
		refreshonly => true,
		require => [
			File['/home/qa/phpfarm/custom'],
			File['/home/qa/phpfarm/src/bzips/pyrus.phar'],
			Exec['get-pear-installer'],
			Package['libxml2-dev'],
			Package['libssl-dev'],
			Package['libbz2-dev'],
			# Not multiarch-ready.
			#Package['libicu-dev'],
			# Puppet cannot handle it apparently.
			#Package['libxslt-dev/sid'],

			Package['libxml2-dev:i386'],
			Package['libssl-dev:i386'],
			Package['libbz2-dev:i386'],
			#Package['libicu-dev:i386'],
			#Package['libxslt-dev:i386/experimental'],
		],
		environment => 'MAKE_OPTIONS=-j7',
	}

	exec {
	"switch-phpfarm":
		command => "/home/qa/phpfarm/inst/bin/switch-phpfarm $main_version",
		creates => '/home/qa/phpfarm/inst/current/bin/php',
		require => Exec['phpfarm'],
	}
}
