# class dukesbank::db
#
#
class dukesbank::db (
  $database = 'dukes_db',
  $username = 'dukes_admin',
  $password = 'dukes_pwd'
) {

  database { $database:
    ensure   => present,
    charset  => 'utf8',
    provider => 'mysql',
  }

  database_user { "${username}@localhost":
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Database[$database],
  }

  database_user { "${username}@%":
    ensure        => present,
    password_hash => mysql_password($password),
    require       => Database[$database],
  }

  database_grant { "${username}@localhost/${database}":
    privileges => [ 'all' ],
    require    => Database_user["${username}@localhost"],
  }
  database_grant { "${username}@%/${database}":
    privileges => [ 'all' ],
    require    => Database_user["${username}@%"],
  }

  $sql = template('dukesbank/create_dukes_bank.sql.erb')

  exec { "${database}-import":
    command     => "/usr/bin/mysql -u ${username} -p${password} -h localhost ${database} < ${sql}",
    logoutput   => true,
    refreshonly => true,
    subscribe   => Database[$database],
    require     => Database_grant["${username}@localhost/${database}", "${username}@%/${database}"],
  }

}
