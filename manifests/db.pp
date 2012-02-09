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

  file { '/opt/dukesbank':
    ensure => directory,
  }

  file { 'create_dukes_bank.sql':
    path    => '/opt/dukes/bank/create_dukes_bank.sql',
    owner   => '0',
    group   => '0',
    mode    => '0400',
    content => template('dukesbank/create_dukes_bank.sql.erb'),
  }

  exec { "${database}-import":
    command     => "/usr/bin/mysql -u ${username} -p${password} -h localhost ${database} < /opt/dukes/bank/create_dukes.bank.sql",
    logoutput   => true,
    refreshonly => true,
    subscribe   => Database[$database],
    require     => [ Database_grant["${username}@localhost/${database}", "${username}@%/${database}"], 
                     File['create_dukes_bank.sql'] ],
  }

}
