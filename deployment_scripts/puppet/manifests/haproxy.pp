notice('MODULAR: tacker/haproxy.pp')

$plugin_hash    = hiera_hash('tacker', {})
$tacker_hash    = $plugin_hash['metadata']
$tacker_port    = $tacker_hash['port']

$network_metadata   = hiera_hash('network_metadata')
$tacker_address_map = get_node_to_ipaddr_map_by_network_role(get_nodes_hash_by_roles($network_metadata, ['tacker']), 'management')

$public_ssl_hash   = hiera('public_ssl')
$ssl_hash          = hiera_hash('use_ssl', {})

$public_ssl        = get_ssl_property($ssl_hash, $public_ssl_hash, 'tacker', 'public', 'usage', false)
$public_ssl_path   = get_ssl_property($ssl_hash, $public_ssl_hash, 'tacker', 'public', 'path', [''])

$internal_ssl      = get_ssl_property($ssl_hash, {}, 'tacker', 'internal', 'usage', false)
$internal_ssl_path = get_ssl_property($ssl_hash, {}, 'tacker', 'internal', 'path', [''])

firewall {'220 tacker':
  port   => [$tacker_port],
  proto  => 'tcp',
  action => 'accept',
}

Openstack::Ha::Haproxy_service {
  internal_virtual_ip => hiera('management_vip'),
  ipaddresses         => values($tacker_address_map),
  public_virtual_ip   => hiera('public_vip'),
  server_names        => keys($tacker_address_map),
}

openstack::ha::haproxy_service { 'tacker':
  order                  => '220',
  listen_port            => $tacker_port,
  public                 => true,
  public_ssl             => $public_ssl,
  public_ssl_path        => $public_ssl_path,
  internal_ssl           => $internal_ssl,
  internal_ssl_path      => $internal_ssl_path,
  haproxy_config_options => {
      'option'         => ['httpchk /', 'httplog', 'httpclose'],
      'http-request'   => 'set-header X-Forwarded-Proto https if { ssl_fc }',
      'timeout server' => '11m',
  },
  balancermember_options => 'check inter 10s fastinter 2s downinter 3s rise 3 fall 3',
}
