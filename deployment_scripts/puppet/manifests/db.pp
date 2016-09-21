notice('MODULAR: tacker/db.pp')

$plugin_hash    = hiera_hash('tacker', {})
$tacker_hash    = $plugin_hash['metadata']
$mysql_hash     = hiera_hash('mysql', {})
$management_vip = hiera('management_vip')
$database_vip   = hiera('database_vip')

$mysql_root_user     = pick($mysql_hash['root_user'], 'root')
$mysql_root_password = $mysql_hash['root_password']

$db_user     = pick($tacker_hash['user'], 'tacker')
$db_name     = pick($tacker_hash['db_name'], 'tacker')
$db_password = pick($tacker_hash['db_password'], $mysql_root_password)

$db_host          = $database_vip
$db_root_user     = $mysql_root_user
$db_root_password = $mysql_root_password

$allowed_hosts = [ 'localhost', '127.0.0.1', '%' ]

validate_string($mysql_root_user)
validate_string($database_vip)

class { 'tacker::db::mysql':
  user          => $db_user,
  password      => $db_password,
  dbname        => $db_name,
  allowed_hosts => $allowed_hosts,
}

class { 'osnailyfacter::mysql_access':
  db_host     => $db_host,
  db_user     => $db_root_user,
  db_password => $db_root_password,
}

Class['osnailyfacter::mysql_access'] ->
  Class['tacker::db::mysql']

class mysql::config {}
include mysql::config
class mysql::server {}
include mysql::server

