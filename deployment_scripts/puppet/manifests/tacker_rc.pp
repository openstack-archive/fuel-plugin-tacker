notice('MODULAR: tacker_rc.pp')

$plugin_hash = hiera_hash('tacker', {})
$tacker_hash = $plugin_hash['metadata']
$public_vip  = hiera('public_vip')

$tacker_tenant        = pick($tacker_hash['tenant'], 'services')
$tacker_user          = pick($tacker_hash['user'], 'tacker')
$tacker_user_password = $tacker_hash['user_password']

$ssl_hash               = hiera_hash('use_ssl', {})
$public_auth_protocol   = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'protocol', 'http')
$public_auth_address    = get_ssl_property($ssl_hash, {}, 'keystone', 'public', 'hostname', $public_vip)
$auth_uri               = "${public_auth_protocol}://${public_auth_address}:5000/v3/"

$tackerc = inline_template("
#!/bin/sh
export LC_ALL=C
export OS_NO_CACHE=true
export OS_TENANT_NAME=<%= @tacker_tenant %>
export OS_PROJECT_NAME=<%= @tacker_tenant %>
export OS_USERNAME=<%= @tacker_user %>
export OS_PASSWORD=<%= @tacker_user_password %>
export OS_AUTH_URL=<%= @auth_uri %>
export OS_IDENTITY_API_VERSION=3
export OS_DEFAULT_DOMAIN=default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_STRATEGY=keystone
export OS_REGION_NAME=RegionOne
export TACKER_ENDPOINT_TYPE=internalURL
")

file { '/root/tackerc':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => $tackerc,
}
