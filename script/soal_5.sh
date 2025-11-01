#!/bin/bash

# in Erendis (DNS Master)
cat <<EOF > /etc/bind/named.conf.local
// Konfigurasi Zona Master
zone "K10.com" {
    type master;
    file "/etc/bind/db.K10.com";
    allow-transfer { 192.216.3.3; };
};

// BARU: Zona Reverse PTR untuk 192.216.3.x
zone "3.216.192.in-addr.arpa" {
    type master;
    file "/etc/bind/db.192.216.3";
    allow-transfer { 192.216.3.3; };
};
EOF

cat <<EOF > /etc/bind/db.192.216.3
; File Zona Reverse PTR untuk 192.216.3.x
$TTL    604800
@       IN      SOA     ns1.K10.com. root.K10.com. (
                        1         ; Serial (Serial baru untuk zona baru)
                   604800         ; Refresh
                    86400         ; Retry
                  2419200         ; Expire
                   604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.K10.com.
@       IN      NS      ns2.K10.com.

; PTR Records (Soal 5)
2       IN      PTR     ns1.K10.com. ; 192.216.3.2
3       IN      PTR     ns2.K10.com. ; 192.216.3.3
EOF
# Manual
cat <<EOF > /etc/bind/db.K10.com
; File Zona untuk K10.com
$TTL    604800
@       IN      SOA     ns1.K10.com. root.K10.com. (
                        3         ; Serial (NAIKKAN DARI 2)
                   604800         ; Refresh
                    86400         ; Retry
                  2419200         ; Expire
                   604800 )       ; Negative Cache TTL
;
; --- Name Servers (dari Soal 4) ---
@       IN      NS      ns1.K10.com.
@       IN      NS      ns2.K10.com.
ns1     IN      A       192.216.3.2
ns2     IN      A       192.216.3.3

; --- A Records (dari Soal 4) ---
Palantir  IN    A       192.216.4.3
Elros     IN    A       192.216.1.6
Pharazon  IN    A       192.216.2.6
Elendil   IN    A       192.216.1.2
Isildur   IN    A       192.216.1.3
Anarion   IN    A       192.216.1.4
Galadriel IN    A       192.216.2.2
Celeborn  IN    A       192.216.2.3
Oropher   IN    A       192.216.2.4

; --- TAMBAHAN SOAL 5 ---
; Alias "www"
www       IN      CNAME   elros.K10.com.

; TXT Records "pesan rahasia"
@         IN      TXT     "Cincin Sauron menunjuk ke Elros"
@         IN      TXT     "Aliansi Terakhir menunjuk ke Pharazon"
EOF

service bind9 restart


# in Amdir (DNS Slave)
cat <<EOF > /etc/bind/named.conf.local
// Konfigurasi Zona Slave
zone "K10.com" {
    type slave;
    file "db.K10.com";
    masters { 192.216.3.2; };
};

// BARU: Zona Reverse PTR untuk 192.216.3.x
zone "3.216.192.in-addr.arpa" {
    type slave;
    file "db.192.216.3";
    masters { 192.216.3.2; };
};
EOF

service bind9 restart

# Cek
# CNAME/ALIAS: dig www.K10.com
# Tes TXT: dig K10.com TXT
# Tes PTR(Reverse Lookup): dig -x 192.216.3.2