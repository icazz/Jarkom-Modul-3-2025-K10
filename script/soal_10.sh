#!/bin/bash
# --- Skrip untuk ELROS (Reverse Proxy Soal 10) ---

echo "Langkah 1: Memperbaiki DNS & IPv4 (Masalah Node Statis)..."
# Perbaikan DNS: Arahkan ke DNS internal (Erendis/Amdir)
cat <<EOF > /etc/resolv.conf
nameserver 192.216.3.2
nameserver 192.216.3.3
EOF
# Perbaikan IPv4: Paksa apt-get menggunakan IPv4
echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

echo "Langkah 2: Menginstal Nginx..."
apt-get update
apt-get install -y nginx

echo "Langkah 3: Menulis konfigurasi Nginx (elros.K10.com)..."
cat <<EOF > /etc/nginx/sites-available/elros.K10.com
# 1. Definisikan Upstream (Soal 10)
# Algoritma Round Robin adalah default
upstream kesatria_numenor {
    server 192.216.1.2:8001;  # Elendil
    server 192.216.1.3:8002;  # isildur
    server 192.216.1.4:8003;  # Anarion
}

# 2. Konfigurasi Server (Reverse Proxy)
server {
    listen 80;
    server_name elros.K10.com;

    location / {
        # Teruskan semua permintaan ke upstream
        proxy_pass http://kesatria_numenor;
        
        # Header penting untuk reverse proxy
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    error_log /var/log/nginx/elros_error.log;
    access_log /var/log/nginx/elros_access.log;
}
EOF

echo "Langkah 4: Mengaktifkan situs elros.K10.com..."
# Hapus default
rm -f /etc/nginx/sites-enabled/default
# Aktifkan situs baru
ln -s /etc/nginx/sites-available/elros.K10.com /etc/nginx/sites-enabled/

echo "Langkah 5: Restart servis Nginx..."
service nginx restart

echo "--- Konfigurasi Elros Selesai ---"

# in Elendil (Worker Laravel)
sed -i 's/server_name elendil.K10.com;/server_name elendil.K10.com elros.K10.com;/' /etc/nginx/sites-available/elendil.K10.com
service nginx restart

# in isildur (Worker Laravel)
sed -i 's/server_name isildur.K10.com;/server_name isildur.K10.com elros.K10.com;/' /etc/nginx/sites-available/isildur.K10.com
service nginx restart

# in Anarion (Worker Laravel)
sed -i 's/server_name anarion.K10.com;/server_name anarion.K10.com elros.K10.com;/' /etc/nginx/sites-available/anarion.K10.com
service nginx restart

# Amandil dan Gilgalad
# 1. Tes Halaman Utama
lynx http://elros.K10.com

# 2. Tes API
curl http://elros.K10.com/api/airing