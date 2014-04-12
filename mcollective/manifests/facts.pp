class mcollective::facts ()
{
	if $kernel == 'windows' {
	file{'C:/qa/mcollective/etc/facts.yaml':
			mode    => 400,
			content => template('mcollective/facts.yaml.erb'),
                	require => Exec['Extract mcollective'],
		}
	}
	else {
		file{'/etc/mcollective/facts.yaml':
			owner    => root,
			group    => root,
			mode     => 400,
			content => template('mcollective/facts.yaml.erb'),
		}
	}
}
