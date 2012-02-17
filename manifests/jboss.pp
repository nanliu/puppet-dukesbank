class dukesbank::jboss (
  $db_host,
  $db_port,
  $database = 'dukes_db',
  $username = 'dukes_admin',
  $password = 'dukes_pwd'
) {

  jboss::deploy { 'dukesbank-2b.ear':
    source => 'puppet:///modules/dukesbank/dukesbank-2b.ear',
  }

  jboss::deploy { 'mysql.jdbc-5.1.6.jar':
    source => 'puppet:///modules/dukesbank/mysql.jdbc-5.1.6.jar',
  }

  jboss::conf { 'jboss-ds.xml':
    content => template('dukesbank/jboss-ds.xml.erb'),
  }

}
