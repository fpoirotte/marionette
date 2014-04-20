class rsnapshot {
	file {
	"/home/backup":
		ensure => directory,
		mode => 0700,		
	}

	file {
	"/root/mysqlbk.sh":
		mode => 0700,
		source => 'puppet:///modules/rsnapshot/mysqlbk.sh',
	}

	file {
	"/root/confbk.sh":
		ensure => absent,
	}

	file {
	"/root/postbk.sh":
		mode => 0700,
		source => 'puppet:///modules/rsnapshot/postbk.sh',
		require => [
			Package['fuse-utils'],
			Package['gnupg'],
			Package['tar'],
			File['/home/backup'],
			File['/root/confbk.sh'],
		],
	}

	netrc::foruser {
	root:
		user => root,
		machine_user_password_triples => [
			['dedibackup-dc1.online.net',
			 extlookup('backup_user'),
			 extlookup('backup_pass')]
		],
	}

	file {
	"/etc/rsnapshot.conf":
		source => 'puppet:///modules/rsnapshot/rsnapshot.conf',
		require => [
			Package['rsnapshot'],
			File['/root/postbk.sh'],
		]
	}

	file {
	"/etc/cron.d/rsnapshot":
		source => 'puppet:///modules/rsnapshot/cron',
		require => [
			Package['cron'],
			File['/etc/rsnapshot.conf'],
		],
		notify => Service['cron'],
	}

	file {
	"/mnt/backup":
		ensure => directory,
		mode => 0700,
	}

	file {
	"/root/.gnupg":
		ensure => directory,
		mode => 0700,
		owner => root,
		group => root,
	}

	file {
	"/root/.gnupg/gpg.conf":
		source => "puppet:///modules/rsnapshot/gnupg/gpg.conf",
		mode => 0600,
		owner => root,
		group => root,
	}

	file {
	"/root/.gnupg/root@erebot.net.sec":
		source => "puppet:///modules/rsnapshot/gnupg/root@erebot.net.sec",
		mode => 0600,
		owner => root,
		group => root,
	}

	exec {
	"gpg-import root@erebot.net":
		command => '/usr/bin/gpg --batch --import /root/.gnupg/root@erebot.net.sec',
		require => File['/root/.gnupg/root@erebot.net.sec', '/root/.gnupg/gpg.conf'],
		unless => '/usr/bin/gpg --list-key root@erebot.net',
	}

	exec {
	"gpg-import clicky@erebot.net":
		command => '/usr/bin/gpg --batch --recv-keys 0xBA79C288F4F0D460',
		require => File['/root/.gnupg/gpg.conf', '/root/.gnupg/gpg.conf'],
		unless => '/usr/bin/gpg --list-key F4F0D460',
	}

	exec {
	"gpg-trust root@erebot.net":
		# Sets the key' trust to ultimate.
		command => '/usr/bin/printf "%s\n" 46E876E8058CB72B105EF6D7994500E6F671E215:6: | /usr/bin/gpg --import-ownertrust',
		require => Exec['gpg-import root@erebot.net'],
	}

	exec {
	"gpg-trust clicky@erebot.net":
		# Sets the key' trust to ultimate.
		command => '/usr/bin/printf "%s\n" D916DBC02A198B0D75137745BA79C288F4F0D460:6: | /usr/bin/gpg --import-ownertrust',
		require => Exec['gpg-import clicky@erebot.net'],
	}

	exec {
	"gpg-check-trustdb":
		command => '/usr/bin/gpg --check-trustdb --batch --no-tty',
		require => Exec['gpg-trust root@erebot.net', 'gpg-trust clicky@erebot.net'],
	}
}
