#!/bin/bash
# ==========================================================
# SOAL 12 & 13: PHP Workers (Galadriel, Celeborn, Oropher)
# Instalasi, Port Unik (8004, 8005, 8006), dan Domain-Only Access
# ==========================================================

# Fungsi untuk mengkonfigurasi Worker
configure_php_worker() {
    local node_name=$1
    local port=$2
    local ip_address=$3

    echo "--- Konfigurasi Worker: $node_name (Port $port) ---"
    
    # in $node_name
    
    # Instalasi Nginx dan PHP 8.4
    apt-get update
    apt-get install -y nginx php8.4-fpm
    
    # Buat direktori web
    mkdir -p /var/www/html
    
    # Buat index.php (termasuk Soal 15 logic)
    cat <<EOF > /var/www/html/index.php
<?php
echo "<h1>Taman $node_name (Node: " . gethostname() . ")</h1>";
echo "<p>Alamat IP Pengunjung: " . (\$_SERVER['HTTP_X_REAL_IP'] ?? \$_SERVER['REMOTE_ADDR']) . "</p>";
?>
EOF
    
    # Konfigurasi Nginx
    cat <<EOF > /etc/nginx/sites-available/${node_name}.K10.com
server {
    listen ${port};
    server_name ${node_name}.K10.com;
    root /var/www/html;
    index index.php index.html;

    location / { try_files \$uri \$uri/ =404; }
    
    # Meneruskan ke PHP-FPM
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    
    # Tolak akses via IP (hanya via domain - Soal 12)
    if (\$host !~* ^${node_name}\.K10\.com\$) {
        return 444; 
    }
}
EOF

    rm -f /etc/nginx/sites-enabled/default
    rm -f /etc/nginx/sites-enabled/${node_name}.K10.com
    ln -s /etc/nginx/sites-available/${node_name}.K10.com /etc/nginx/sites-enabled/
    
    service php8.4-fpm restart
    service nginx restart
}

# --- Jalankan di setiap Worker PHP ---
# Lakukan ini secara berurutan di setiap node: Galadriel, Celeborn, Oropher
# Di Galadriel (192.216.2.2)
# configure_php_worker "galadriel" "8004" "192.216.2.2"

# Di Celeborn (192.216.2.3)
# configure_php_worker "celeborn" "8005" "192.216.2.3"

# Di Oropher (192.216.2.4)
# configure_php_worker "oropher" "8006" "192.216.2.4"