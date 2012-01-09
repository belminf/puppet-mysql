define mysql::grant_access ( $user, $password, $db, $mysql_root_password, $host='localhost', $perms='ALL' ) {

	$mysql_root_cmd = "mysql -uroot -p${mysql_root_password} -e"

	Exec {
		path => ['/bin', '/usr/bin'],
	}

	exec { "grant_db_access-${name}":
		command => "${mysql_root_cmd} \"GRANT ${perms} ON ${db}.* TO '${user}'@'${host}' IDENTIFIED BY '$password';\"",
		refreshonly => true,
	}

	exec { "clear_db_access-${name}":
		unless => "${mysql_root_cmd} \"SHOW GRANTS FOR '${user}'@'${host}';\" | grep -i '${perms}' && ${mysql_root_cmd} \"SELECT 'TRUE' FROM mysql.user WHERE user='${user}' AND host='${host}' AND password=PASSWORD('${password}')\" | grep 'TRUE'",
		command =>  "${mysql_root_cmd} \"REVOKE ALL ON ${db}.* FROM '${user}'@'${host}';\"",
		returns => [0,1],
		require => Service['mysqld'],
		notify =>  [Exec["grant_db_access-${name}"],  Exec['set-mysql-password'],],
	}


}

define mysql::create_db ( $db, $mysql_root_password ) { 

	$mysql_root_cmd = "mysql -uroot -p${mysql_root_password} -e"

	exec { "create_db-${name}":
		path => ['/bin', '/usr/bin'],
		unless => "${mysql_root_cmd} ${db} \"exit\"",
		command => "${mysql_root_cmd} \"CREATE DATABASE ${db};\"",
		require => [Service['mysqld'], Exec['set-mysql-password'],],
	}
}
