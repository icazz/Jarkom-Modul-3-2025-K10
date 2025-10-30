# --- Skrip BARU Soal 3 untuk MINASTIR (DNS Forwarder) ---

echo "Menginstal BIND9..."
apt-get update
apt-get install -y bind9

echo "Mengkonfigurasi BIND9 sebagai Forwarder-Only..."
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";

    # Izinkan query dari semua subnet internal kita
    allow-query { 192.216.0.0/16; };
    
    # Teruskan SEMUA query ke DNS Internet (misal: NAT GNS3)
    forwarders {
        192.168.122.1;
        8.8.8.8;
    };
    forward only; # Ini menjadikannya murni forwarder

    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

# PERBAIKAN: Buat file local kosong (agar named.conf tidak error)
touch /etc/bind/named.conf.local

echo "Restart BIND9..."
service bind9 restart

echo "--- Konfigurasi Minastir Selesai ---"

# --- Skrip Update DNS untuk ERENDIS & AMDIR ---

echo "Mengkonfigurasi ulang forwarder ke Minastir..."
cat <<EOF > /etc/bind/named.conf.options
options {
    directory "/var/cache/bind";
    allow-query { 192.216.0.0/16; };
    # PERUBAHAN: Teruskan query (seperti google.com)
    # ke DNS Forwarder kita (Minastir)
    forwarders {
        192.216.5.2;
    };

    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

echo "Restart BIND9..."
service bind9 restart

echo "--- Konfigurasi Forwarder Selesai ---"

# in Durin

sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -o eth0 -s 192.216.3.0/24 -j MASQUERADE
iptables -P FORWARD DROP
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth4 -s 192.216.3.0/24 -o eth0 -j ACCEPT
iptables -A FORWARD -d 192.216.3.2 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -d 192.216.3.3 -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -i eth1 -s 192.216.1.0/24 -d 192.216.4.3 -p tcp --dport 3306 -j ACCEPT

# Cek di Gilgalad
dig google.com
dig elros.K10.com