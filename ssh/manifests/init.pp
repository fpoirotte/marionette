class ssh {
	file {
	"/etc/ssh/sshd_config":
		mode => 0600,
		source => "puppet:///modules/ssh/sshd_config",
		require => Package['openssh-server'],
		notify => Service['ssh'],
	}

        file {
        "/root/.ssh":
                ensure => directory,
                mode => 0755,
		require => Package['openssh-server'],
        }

	ssh_authorized_key {
	"root@dss":
		user => root,
		type => 'ssh-dss',
		key => 'AAAAB3NzaC1kc3MAAACBAMTour9svbZsEZ9MgyuT+xmlEKKv+KWDZhJizU/uPGCnMK/llSeC9N2QvMUuXKiOqDP8VZ6rSfJMskWMlEW+qJS/+EBZumDhYbEDH2LTBumnN8ufhCx56czN45tWWAK0Zl+lPPl4hU2Do754tMmZoIXFmpZzKIXgGwdyV9MHUrA5AAAAFQDAbaNb7DlkG7EXeoGipLMRKxq4sQAAAIEAg0495q0ncsVXItNifjHc243yCJv9m24NLj4utol6DQ+kCJ4miM7IfNwGkgWaP/w/5IQ8NotA6SWPkHRQjZwJk4aROo3USS+uocVDN+d9BYqdAuEiF2jSMMxGZx58Od3VZheK8lOiC698S/YcR/g/VfaYXBuOBs4YwEBS2ipj8pAAAACAL05Mlhx0tvHmj9bz6vwOVBZRSy4HoNj5fqqZU0dACzTXqnVO8u6cXT1Q4cBbnbMYVlFF502jhU1s3pv67vaLXGDQc0HMvy7gy73TRLROXBm3u1F/5IhObKuIMdRMJoMcEeKVlClgm/8+i4jOV+8Ir8H0N433VCDU62Uons/RHl0=',
		;
	"root@rsa":
		user => root,
		type => 'ssh-rsa',
		key => 'AAAAB3NzaC1yc2EAAAABIwAAAgEA1U4RUyLlMgmDZof57btd+ncBNH3AxsbvddSilyOUcGEKSRY3rXvIxft+r/E//u+Dd9fu4hni8Zxa6bCqgvI8T4EdyQhQWPwuudvHxupCJoeVqYdTMYa7vzSwmoZ2QsBbvWddu/3OyudJeFwZRnpeRxDNS843HXuJ4wvswuz5+ptEIGxLmv9oU9j6Ha+BPlDXMir/fGipARyAg/LbB3jYfl5YflSzj4h4jQERDdQ1qqPnUds8PjT4jpzBp1EGGivl8x1S35fp+TRZqrJCosdcU4njlrqkyaoPUWzO0EpJ/yEFXZeM9yB59hiQLkO/T52oGNzRDiV/maq8am5XD9dhb9sBi8x6Ak3fy33Nc8lXKBEd73eh9kQlG7cLYwKvL0j/4KbKDm8kY41mFqZXcXcmX6YktgAZq1sbxGd+flDcWy1eLdOw3KaRNJy6D4ad82rTO27/XEEo6k5pkTSRqMiGtSiNTV6+CsraDSTToEa01ARmKEVUYwr6W+Git6HvXF2U4KulE3MqdyJsVGGMHEqepjrOpWnnN18OAyRw2R1HMGHqphL4IWSBh9O9ktto5S9xWp0VTj/FRHNqJSC8pRJA/La6eTCQAuzsywPHhW9ssKMDSH4deDGMdEv3z2fvBo2yTICh0y5tIQBNd7Pwuhj+Hqx88+KZRz6JRCVj9mO18Gc=',
		;
	}

	file {
	"/root/.ssh/authorized_keys2":
		ensure => link,
		require => Package['openssh-server'],
		target => '/etc/ssh/ssh_host_dsa_key.pub',
	}

	file {
	"/etc/issue":
		ensure => present,
		content => template('ssh/issue'),
		require => Package['openssh-server'],
	}
}
