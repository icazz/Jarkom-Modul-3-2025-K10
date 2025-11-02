#!/bin/bash

# ==========================================================
#  Konfigurasi Rate Limiting di Elros (Laravel LB) & Pharazon (PHP LB)
# ==========================================================

# --- Di Elros & Pharazon ---
echo "Menambahkan Rate Limiting Zone ke Nginx Global Config di Elros dan Pharazon..."

# 1. Tambahkan konfigurasi di blok 'http' di /etc/nginx/nginx.conf
# Zone: ip_limit, Size: 10MB, Rate: 10 requests per second (10r/s)
# Gunakan $binary_remote_addr untuk efisiensi memori.
sudo sed -i '/http {/a \ \ \ \ limit_req_zone \$binary_remote_addr zone=ip_limit:10m rate=10r/s;' /etc/nginx/nginx.conf


# --- Konfigurasi di Elros (Laravel Load Balancer) ---
echo "Menerapkan Rate Limiting di Elros..."

# Menggunakan konfigurasi sebelumnya, tambahkan limit_req di location
cat <<EOF > /etc/nginx/sites-available/elros.K10.com
log_format upstream_custom '\$remote_addr - \$remote_user [\$time_local] '
                             '"\$request" \$status \$body_bytes_sent '
                             '"\$http_referer" "\$http_user_agent" '
                             'upstream="\$upstream_addr"';

upstream kesatria_numenor {
    server 192.216.1.2:8001 weight=2;  # Elendil
    server 192.216.1.3:8002 weight=2;  # Isildur
    server 192.216.1.4:8003;           # Anarion
}

server {
    listen 80;
    server_name elros.K10.com;

    access_log /var/log/nginx/elros_access.log upstream_custom;
    error_log /var/log/nginx/elros_error.log;

    location / {
        # Rate Limiting: Membatasi 10r/s, mengizinkan burst 20 requests, tanpa penundaan (nodelay)
        limit_req zone=ip_limit burst=20 nodelay; 
        
        proxy_pass http://kesatria_numenor;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        
        proxy_http_version 1.1;
        proxy_set_header Connection "";
    }
}
EOF

sudo nginx -t
sudo service nginx restart


# --- Konfigurasi di Pharazon (PHP Load Balancer) ---
echo "Menerapkan Rate Limiting di Pharazon..."

# Menggunakan konfigurasi sebelumnya, tambahkan limit_req di location
cat <<EOF > /etc/nginx/sites-available/pharazon.K10.com

upstream kesatria_lorien {
    server 192.216.2.2:8004;  # Galadriel
    server 192.216.2.3:8005;  # Celeborn
    server 192.216.2.4:8006;  # Oropher
}

server {
    listen 80;
    server_name pharazon.K10.com;

    location / {
        # Rate Limiting
        limit_req zone=ip_limit burst=20 nodelay; 
        
        proxy_pass http://kesatria_lorien;
        
        proxy_set_header Authorization \$http_authorization; 

        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header Host \$host;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
    
    if (\$host !~* ^pharazon\.K10\.com\$) {
        return 444; 
    }
}
EOF

sudo nginx -t
sudo service nginx restart


# --- Uji Coba Rate Limiting (Dilakukan di Client: Amandil) ---
echo "Menginstal ApacheBench di Amandil (Client) untuk pengujian..."
# in Amandil
sudo apt-get update
sudo apt-get install -y apache2-utils

echo "Meluncurkan uji coba ke Elros (100 requests, 50 concurrent)"
# in Amandil
ab -n 100 -c 50 http://elros.K10.com/api/airing

echo "--- VERIFIKASI ---"
echo "Cek Log Error di Elros untuk melihat pesan 'limiting requests'"
# in Elros
# tail /var/log/nginx/elros_error.log | grep "limiting requests"

echo "Meluncurkan uji coba ke Pharazon (100 requests, 50 concurrent, dengan auth)"
# in Amandil
ab -n 100 -c 50 -A noldor:silvan http://pharazon.K10.com/

echo "Cek Log Error di Pharazon untuk melihat pesan 'limiting requests'"
# in Pharazon
# tail /var/log/nginx/error.log | grep "limiting requests"