notice('MODULAR: tacker.pp')

$management_vip = hiera('management_vip')
$public_vip     = hiera('public_vip')
$network_scheme = hiera_hash('network_scheme', {})
prepare_network_config($network_scheme)

$plugin_hash = hiera_hash('tacker', {})
$debug       = $plugin_hash['debug']
$tacker_hash = $plugin_hash['metadata']
$odl         = hiera_hash('opendaylight', {})
$odl_port    = $odl['rest_api_port']

$bind_port    = $tacker_hash['port']
$bind_host    = get_network_role_property('management', 'ipaddr')
$service_name = pick($tacker_hash['service'], 'tacker-server')

$tacker_tenant        = pick($tacker_hash['tenant'], 'services')
$tacker_user          = pick($tacker_hash['user'], 'tacker')
$tacker_user_password = pick($tacker_hash['user'], 'tacker')

$ssl_hash               = hiera_hash('use_ssl', {})
$public_auth_protocol = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'protocol', 'http')
$public_auth_address  = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'hostname', $public_vip)
$admin_auth_protocol    = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'protocol', 'http')
$admin_auth_address     = get_ssl_property($ssl_hash, {}, 'keystone', 'admin', 'hostname', $management_vip)

$auth_uri     = "${public_auth_protocol}://${public_auth_address}:5000/v2.0/"
$identity_uri = "${admin_auth_protocol}://${admin_auth_address}:35357/"
$heat_uri     = "${admin_auth_protocol}://${admin_auth_address}:8004/v1"

$database_vip = hiera('database_vip', undef)
$db_type      = 'mysql'
$db_host      = pick($tacker_hash['db_host'], $database_vip)
$db_user      = pick($tacker_hash['username'], 'tacker')
$db_password  = $tacker_hash['db_password']
$db_name      = pick($tacker_hash['db_name'], 'tacker')

$db_connection = os_database_connection({
  'dialect'  => $db_type,
  'host'     => $db_host,
  'database' => $db_name,
  'username' => $db_user,
  'password' => $db_password,
  'charset'  => 'utf8'
})

$rabbit_hash        = hiera_hash('rabbit', {})
$rabbit_hosts       = split(hiera('amqp_hosts',''), ',')
$rabbit_password    = $rabbit_hash['password']
$rabbit_userid      = $rabbit_hash['user']

class { 'tacker':
  keystone_password   => $tacker_user_password,
  keystone_tenant     => $tacker_tenant,
  keystone_user       => $tacker_user,
  auth_uri            => $auth_uri,
  identity_uri        => $identity_uri,
  database_connection => $db_connection,
  rabbit_hosts        => $rabbit_hosts,
  rabbit_password     => $rabbit_password,
  rabbit_userid       => $rabbit_userid,
  bind_port           => $bind_port,
  bind_host           => $bind_host,
  service_name        => $service_name,
  debug               => $debug,
  opendaylight_host   => $management_vip,
  opendaylight_port   => $odl_port,
  heat_uri            => $heat_uri,
}

