#!/bin/sh

wget -N http://mirrors.kernel.org/ubuntu/pool/universe/p/python-iniparse/python-iniparse_0.4-2.1build1_all.deb
wget -N http://archive.ubuntu.com/ubuntu/pool/universe/c/crudini/crudini_0.3-1_amd64.deb
dpkg -i python-iniparse_0.4-2.1build1_all.deb crudini_0.3-1_amd64.deb


    auth_uri=$(crudini --get '/etc/heat/heat.conf' 'keystone_authtoken' 'auth_uri')

    cat > tackerc <<EOFRC
#!/bin/sh
export LC_ALL=C
export OS_NO_CACHE='true'
export OS_TENANT_NAME='services'
export OS_PROJECT_NAME='services'
export OS_USERNAME='tacker'
export OS_PASSWORD='tacker'
export OS_AUTH_URL='${auth_uri}'
export OS_DEFAULT_DOMAIN='default'
export OS_AUTH_STRATEGY='keystone'
export OS_REGION_NAME='RegionOne'
export TACKER_ENDPOINT_TYPE='internalURL'
EOFRC
    chmod +x tackerc
    mv tackerc /root/

