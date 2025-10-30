#!/bin/bash
# tambahkan ini dulu atau matikan server
nameserver 192.216.3.2
nameserver 192.216.3.3
# Instalasi Worker Laravel (Elendil, Esildur, Anarion)
# Step 1
echo "Instalasi Nginx, Git, dan dependensi PPA"
apt-get update
apt-get install -y nginx git curl unzip wget lsb-release ca-certificates apt-transport-https

# Step 2
echo "Menambahkan repository PHP 8.4 (Sury)..."
wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list

# Step 3
echo "Instal PHP 8.4 dan Composer..."
apt-get update
apt-get install -y php8.4-fpm php8.4-cli php8.4-mysql php8.4-xml php8.4-mbstring php8.4-curl php8.4-zip
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Step 4
echo "Mendapatkan 'cetak biru' (clone Laravel)..."
git config --global http.proxy $http_proxy
mkdir -p /var/www/
# Hapus folder lama jika ada, untuk memastikan clone bersih
rm -rf /var/www/laravel-api
git clone https://github.com/elshiraphine/laravel-simple-rest-api.git /var/www/laravel-api

# Step 5
echo "Instal dependensi Laravel (REVISI)..."
cd /var/www/laravel-api

# --- PERUBAHAN DI SINI ---
# Kita gunakan 'update' untuk mendapatkan paket yang kompatibel dengan PHP 8.4
echo "Menjalankan 'composer update' (ini mungkin perlu waktu)..."
composer update --no-dev

# Salin file .env untuk persiapan Soal 8
cp .env.example .env

echo "--- Instalasi Soal 7 Selesai ---"