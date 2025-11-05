#!/bin/bash

# in Erendis (DNS Master)
apt-get install bind9 -y
ln -s /etc/init.d/named /etc/init.d/bind9

cat <<EOF > /etc/bind/named.conf.local
// Konfigurasi Zona Master
zone "K10.com" {
    type master;
    file "/etc/bind/db.K10.com"; // Path ke file zona
    allow-transfer { 192.216.3.3; };    // Izinkan transfer HANYA ke Amdir
};
EOF

cat <<EOF > /etc/bind/db.K10.com
; File Zona untuk K10.com
\$TTL    604800
@       IN      SOA     ns1.K10.com. root.K10.com. (
                        2         ; Serial (Ubah ini jika Anda mengedit file)
                   604800         ; Refresh
                    86400         ; Retry
                  2419200         ; Expire
                   604800 )       ; Negative Cache TTL
;
; Name Servers
@       IN      NS      ns1.K10.com.
@       IN      NS      ns2.K10.com.

; Alamat IP Name Servers
ns1     IN      A       192.216.3.2     ; IP Erendis
ns2     IN      A       192.216.3.3     ; IP Amdir

; A Records untuk Lokasi Penting (Soal 4)
palantir  IN    A       192.216.4.3
elros     IN    A       192.216.1.6
pharazon  IN    A       192.216.2.6
elendil   IN    A       192.216.1.2
isildur   IN    A       192.216.1.3
anarion   IN    A       192.216.1.4
galadriel IN    A       192.216.2.2
celeborn  IN    A       192.216.2.3
oropher   IN    A       192.216.2.4
EOF

service bind9 restart
service bind9 status

# in Amdir (DNS Slave)
apt-get install bind9 -y

cat <<EOF > /etc/bind/named.conf.local
// Konfigurasi Zona Slave
zone "K10.com" {
    type slave;
    file "db.K10.com";
    masters { 192.216.3.2; };   // IP Master (Erendis)
};
EOF

service bind9 restart
service bind9 status

# Cek
# Matikan dulu iptables dropnya
# in Amandil
dhclient -r
dhclient eth0
cat /etc/resolv.conf
# Output: nameserver 192.216.3.2 dan nameserver 192.216.3.3

apt-get update
apt-get install -y dnsutils

dig elros.K10.com
dig @192.216.3.3 palantir.K10.com