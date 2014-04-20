class mysql {
	file {
	'/etc/mysql/my.cnf':
		source => 'puppet:///modules/mysql/my.cnf',
		notify => Service['mysql'],
	}

	define mysqldb($user = undef) {
		if $user == undef {
			$realuser = $name
		}
		else {
			$realuser = $user
		}
		$password = extlookup("mysql_$realuser")
		$db_query = "CREATE DATABASE $name"
		$user_query = "GRANT ALL ON ${name}.* TO ${realuser}@localhost IDENTIFIED BY '$password'"
		$test_query = "SELECT COUNT(1) FROM mysql.db WHERE User='$realuser' AND Host='localhost' AND Db='$name'"
		exec {
		"mysql-db-$name":
			command => "/usr/bin/mysql -u root -e \"$db_query\"",
			creates => "/var/lib/mysql/$name/",
			require => [
				Service['mysql'],
			],
		}
		exec {
		"mysql-grant-$name-$realuser":
			command => "/usr/bin/mysql -u root -e \"$user_query\"",
			unless => "/usr/bin/test 1 -eq `/usr/bin/mysql -u root -Nse \"$test_query\"`",
			require => [
				Service['mysql'],
				Exec["mysql-db-$name"],
			],
		}
	}

	mysqldb {[
		buildbot,
		piwik,
		www,
		mediatech,
	]:}
}
