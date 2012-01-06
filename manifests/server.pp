class mysql::server( $password ) {
	
	package { 'mysql-server': ensure => installed }
	package { 'mysql': ensure => installed }

	service { 'mysqld':
		enable => true,
		ensure => running,
		require => Package['mysql-server'],
	}

	file { '/etc/my.cnf':
		owner => 'root',
		group => 'root',
		mode => 644,
		source => [
			'puppet:///modules/mysql/my.cnf/$host.cnf',
			'puppet:///modules/mysql/my.cnf/default.cnf',
		],
		notify => Service['mysqld'],
		require => Package['mysql-server'],
	}
 
	exec { 'set-mysql-password':
		unless => "mysqladmin -uroot -p$password status",
		path => ['/bin', '/usr/bin'],
		command => "mysqladmin -uroot password $password",
		require => Service['mysqld'],
	}
}
