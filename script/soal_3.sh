# --- Skrip BARU Soal 3 untuk MINASTIR (DNS Forwarder) ---
# 192.216.5.2 (minastir)
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
    };
    forward only; # Ini menjadikannya murni forwarder

    dnssec-validation auto;
    listen-on-v6 { any; };
};
EOF

# PERBAIKAN: Buat file local kosong (agar named.conf tidak error)
touch /etc/bind/named.conf.local
service bind9 restart


# Cek di Gilgalad
dig google.com
dig elros.K10.com