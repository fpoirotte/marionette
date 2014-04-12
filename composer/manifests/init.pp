class composer {
        $phpfarm = "/home/qa/phpfarm/inst/current/bin/"

	file {
	"/var/www/php":
		ensure => directory,
		owner => 'www-data',
		group => 'www-data',
	}

        exec {
        "composer-install":
                command => 'php -r "eval(\'?>\'.file_get_contents(\'https://getcomposer.org/installer\'));"',
                cwd => '/var/www',
                user => 'www-data',
                group => 'www-data',
                path => [$phpfarm],
                require => Exec['switch-phpfarm'],
                creates => '/var/www/composer.phar',
        }

        exec {
        "composer-update":
                command => 'php composer.phar self-update',
                cwd => '/var/www',
                user => 'www-data',
                group => 'www-data',
                path => [$phpfarm],
                require => [
                        Exec['composer-install'],
                ],
        }

	define composer($pkg = $label, $stability = 'dev', $destdir = undef) {
		if $destdir == undef {
			if $name =~ /^([^\/]+)\/([^\/]+)$/ {
				$newDestDir = $2
			}
			else {
				fail('Bad destination directory')
			}
		}
		else {
			$newDestDir = $destdir
		}

		exec {
		"composer-install-$name":
			command => "php composer.phar create-project --stability=${stability} ${name} php/${newDestDir}",
			cwd => '/var/www/',
			creates => "/var/www/php/${newDestDir}",
			user => 'www-data',
			group => 'www-data',
			path => [$composer::phpfarm, '/bin', '/usr/bin'],
			require => [
				File['/var/www/php'],
				Exec['composer-update'],
			],
		}
	}

	composer {
	"piwik/piwik":
		stability => stable,
		;
	"composer/satis":
		;
	}
}
