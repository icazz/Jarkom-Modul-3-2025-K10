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
$TTL    604800
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
Palantir  IN    A       192.216.4.3
Elros     IN    A       192.216.1.6
Pharazon  IN    A       192.216.2.6
Elendil   IN    A       192.216.1.2
Isildur   IN    A       192.216.1.3
Anarion   IN    A       192.216.1.4
Galadriel IN    A       192.216.2.2
Celeborn  IN    A       192.216.2.3
Oropher   IN    A       192.216.2.4
EOF

service bind9 restart
service bind9 status

# in Amdir (DNS Slave)
apt-get install bind9 -y

# PERBAIKAN: Tambahkan named.conf.options
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    forwarders {
        192.216.5.2; # <-- Meneruskan ke Minastir
    };
    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

cat <<EOF > /etc/bind/named.conf.local
// Konfigurasi Zona Slave
zone "K10.com" {
    type slave;
    file "db.K10.com";          // BIND akan otomatis membuat file ini dari master
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

dig Elros.K10.com
dig @192.216.3.3 Palantir.K10.com