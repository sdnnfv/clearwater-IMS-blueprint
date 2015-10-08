#!/bin/bash
ctx logger info "starting DNS..."
# Install BIND.
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install bind9 --yes
# Update BIND configuration with the specified zone and key.
cat >> /etc/bind/named.conf.local << EOF

key example.com. {
  algorithm "HMAC-MD5";
  secret "8r6SIIX/cWE6b0Pe8l2bnc/v5vYbMSYvj+jQPP4bWe+CXzOpojJGrXI7iiustDQdWtBHUpWxweiHDWvLIp6/zw==";
};


zone "example.com" IN {
  type master;
  file "/var/lib/bind/db.example.com";
  allow-update {
    key example.com.;
  };
};

zone "openstacklocal" {type master; file "/etc/bind/openstack.local";};

EOF

cat > /etc/bind/openstacklocal.local << EOF
;
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     openstacklocal. root.openstacklocal. (
                           2         ; Serial
                          604800         ; Refresh
                          86400         ; Retry
                          2419200         ; Expire
                          604800 )       ; Negative Cache TTL
;
@       IN      NS      openstacklocal.
;@      IN      A       127.0.0.1
;@      IN      AAAA    ::1
EOF

# Create basic zone configuration.
ctx logger info "DNS IP address is ${dns_ip} bbbbbbllllaaaaaa"
echo ${dns_ip} > /home/ubuntu/dnsfile
cat > /var/lib/bind/db.example.com<< EOF                    
; example.com
\$ORIGIN example.com.
\$TTL 1h
@ IN SOA ns admin\@example.com. ( $(date +%Y%m%d%H) 1d 2h 1w 30s )
@ NS ns
ns A $(hostname -I) 
EOF
chown root:bind /var/lib/bind/db.example.com
# Now that BIND configuration is correct, kick it to reload.
service bind9 reload

