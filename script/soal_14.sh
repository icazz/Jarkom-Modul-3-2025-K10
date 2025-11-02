#!/bin/bash
# Basic HTTP Authentication (user: noldor, pass: silvan)


# Fungsi untuk menambahkan Basic Auth ke Worker
add_basic_auth() {
    local node_name=$1
    
    echo "--- Menambahkan Basic Auth di $node_name ---"
    
    # in $node_name
    
    # Instal htpasswd utility (biasanya ada di apache2-utils)
    apt-get update
    apt-get install -y apache2-utils
    
    # Buat file password (.htpasswd)
    # Membuat user 'noldor' dengan pass 'silvan'
    htpasswd -cb /etc/nginx/.htpasswd noldor silvan
    chmod 644 /etc/nginx/.htpasswd

    # Ambil konfigurasi Nginx yang sudah ada
    CONFIG_FILE="/etc/nginx/sites-available/${node_name}.K10.com"
    
    # Cek apakah Basic Auth sudah ada, jika belum, tambahkan
    if ! grep -q "auth_basic" ${CONFIG_FILE}; then
        sed -i '/listen /a \ \ \ \ auth_basic "Akses Terbatas untuk Noldor";\n\ \ \ \ auth_basic_user_file /etc/nginx/.htpasswd;' ${CONFIG_FILE}
    fi
    
    service nginx restart
}

# --- Jalankan di setiap Worker PHP ---
# Di Galadriel
# add_basic_auth "galadriel"

# Di Celeborn
# add_basic_auth "celeborn"

# Di Oropher
# add_basic_auth "oropher"