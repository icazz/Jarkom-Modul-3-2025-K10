#!/bin/bash

# in Amandil/Gilgalad
apt-get update
apt-get install -y apache2-utils

# Serangan Awal: 100 permintaan, 10 bersamaan
echo "Serangan Awal: 100 Requests, 10 Concurrent..."
ab -n 100 -c 10 http://elros.K10.com/api/airing

# Serangan Penuh: 2000 permintaan, 100 bersamaan
echo "Serangan Penuh: 2000 Requests, 100 Concurrent..."
ab -n 2000 -c 100 http://elros.K10.com/api/airing


# --- BAGIAN 2: Strategi Bertahan (Tambahkan Weight) (Di Elros) ---
echo "--- BAGIAN 2: Menerapkan Weight di Elros (Elros) ---"
# in Elros

cat <<EOF > /etc/nginx/sites-available/elros.K10.com
# Menggunakan log format yang sudah didefinisikan di soal 10
log_format upstream_custom '\$remote_addr - \$remote_user [\$time_local] '
                             '"\$request" \$status \$body_bytes_sent '
                             '"\$http_referer" "\$http_user_agent" '
                             'upstream="\$upstream_addr"';

upstream kesatria_numenor {
    # Elendil (1.2) dan Isildur (1.3) mendapat beban 2x lipat dari Anarion (1.4)
    server 192.216.1.2:8001 weight=2;  # Elendil
    server 192.216.1.3:8002 weight=2;  # Isildur
    server 192.216.1.4:8003;           # Anarion (default weight=1)
}

server {
    listen 80;
    server_name elros.K10.com;

    access_log /var/log/nginx/elros_access.log upstream_custom;
    error_log /var/log/nginx/elros_error.log;

    location / {
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
EOF

nginx -t
service nginx restart

echo "--- Ulangi Uji Beban untuk melihat distribusi weight (Di Amandil/Gilgalad) ---"
# in Amandil/Gilgalad
ab -n 2000 -c 100 http://elros.K10.com/api/airing