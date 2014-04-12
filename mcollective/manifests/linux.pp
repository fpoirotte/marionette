class mcollective::linux {
	$libdir      = $osfamily ? {
                "RedHat"	=> '/usr/libexec/mcollective',
		"Debian"	=> '/usr/share/mcollective/plugins',
        }
	$logfile     = '/var/log/mcollective.log'
	$plugin_yaml = '/etc/mcollective/facts.yaml'
	$stomp       = $osfamily ? {
		"RedHat"	=> 'rubygem-stomp',
		"Debian"	=> 'ruby-stomp',
	}
        $mco_server  = extlookup('mco_server')
	$mco_pass    = extlookup('mco_pass')
	$puppet_bin  = "puppet"

	package { "$stomp":
		ensure => latest,
	}

	package { 'mcollective':
		ensure  => latest,
		require => Package["$stomp"],
	}

	package { [
		"mcollective-puppet-agent",
		"mcollective-package-agent",
		"mcollective-service-agent",
		"mcollective-facter-facts",
	]:
		ensure => latest,
		notify => Service['mcollective'],
	}

	file { '/etc/mcollective/server.cfg':
		content => template('mcollective/server.cfg.erb'),
		owner   => root,
		group   => root,
		mode    => 0640,
		require => Package['mcollective'],
		notify  => Service['mcollective'],
	}

	service { 'mcollective':
                ensure  => running,
                enable  => true,
		require => File['/etc/mcollective/server.cfg'],
	}
}
