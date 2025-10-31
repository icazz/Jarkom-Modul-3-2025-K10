#!/bin/bash

cat <<EOF > /etc/resolv.conf
nameserver 192.216.3.2
nameserver 192.216.3.3
nameserver 192.168.122.1
EOF

echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

echo "Langkah 2: Instalasi Nginx, Git, dan PHP 8.4..."
apt-get update
apt-get install -y nginx git php8.4-fpm php8.4-cli php8.4-mysql php8.4-xml php8.4-mbstring php8.4-curl php8.4-zip

apt-get install -y curl unzip
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

rm -rf /var/www/laravel-simple-rest-api
mkdir -p /var/www/

git clone https://github.com/elshiraphine/laravel-simple-rest-api.git /var/www/laravel-simple-rest-api

cd /var/www/laravel-simple-rest-api

composer update --no-dev

cp .env.example .env

cat > .env << EOF
APP_NAME=Laravel
APP_ENV=local
APP_KEY=
APP_DEBUG=true
APP_URL=http://localhost

DB_CONNECTION=mysql
DB_HOST=192.216.4.3
DB_PORT=3306
DB_DATABASE=laravel_db
DB_USERNAME=laravel_user
DB_PASSWORD=password123
EOF

php artisan key:generate