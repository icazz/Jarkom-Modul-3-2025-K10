#!/bin/bash
# in Pharazon

# ==========================================================
#  Aktivasi Nginx Caching di Pharazon (PHP Load Balancer)
# ==========================================================

echo "1. Membuat direktori cache dan mengatur izin..."
# Direktori cache harus dibuat dan dapat diakses oleh Nginx
sudo mkdir -p /var/cache/nginx
sudo chown -R www-data:www-data /var/cache/nginx

echo "2. Menambahkan Cache Zone ke Nginx Global Config (/etc/nginx/nginx.conf)..."
# Definisikan proxy_cache_path di blok http {}
# keys_zone=php_cache:10m: Shared memory 10MB untuk menyimpan metadata cache.
# inactive=60m: File cache dihapus jika tidak diakses selama 60 menit.
if ! grep -q "keys_zone=php_cache" /etc/nginx/nginx.conf; then
    sudo sed -i '/http {/a \ \ \ \ proxy_cache_path /var/cache/nginx levels=1:2 keys_zone=php_cache:10m inactive=60m;' /etc/nginx/nginx.conf
fi


echo "3. Menerapkan Caching di Server Block Pharazon..."

# Menggunakan konfigurasi sebelumnya (termasuk Rate Limit dari Soal 19)
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
        # Rate Limiting (dari Soal 19)
        limit_req zone=ip_limit burst=20 nodelay; 
        
        # Caching: Gunakan zone php_cache
        proxy_cache php_cache;
        
        # Cache respons 200 (OK) selama 1 menit (1m)
        proxy_cache_valid 200 1m; 
        
        # Tambahkan header untuk melihat status cache (MISS/HIT)
        add_header X-Proxy-Cache \$upstream_cache_status;

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


# --- Uji Coba Caching (Dilakukan di Client: Amandil/Gilgalad) ---
echo "--- VERIFIKASI CACHING ---"
echo "Pastikan 'curl' terinstal di client"

echo "Percobaan 1: MISS (Request pertama, harus masuk ke worker)"
# in Amandil/Gilgalad
# curl -I -u noldor:silvan http://pharazon.K10.com/

echo "Percobaan 2: HIT (Request kedua, harus dilayani dari cache)"
# in Amandil/Gilgalad
# curl -I -u noldor:silvan http://pharazon.K10.com/
# Output diharapkan: Header 'X-Proxy-Cache: HIT'