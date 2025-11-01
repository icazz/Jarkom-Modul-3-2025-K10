# in Palantir

cat <<EOF > /etc/resolv.conf
nameserver 192.216.3.2
nameserver 192.216.3.3
nameserver 192.168.122.1
EOF

echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

apt-get update
apt-get install -y mariadb-server

sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

service mariadb restart
# jalankan ini
mysql -u root 
# lalu masukkan
<<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS laravel_db;
CREATE USER 'laravel_user'@'%' IDENTIFIED BY 'password123';
GRANT ALL PRIVILEGES ON laravel_db.* TO 'laravel_user'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT


# in worker (Elendil)
cat <<EOF > /etc/nginx/sites-available/elendil.K10.com
server {
    listen 8001;
    server_name elendil.K10.com elros.K10.com;
    root /var/www/laravel-simple-rest-api/public;
    index index.php;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    location ~ /\.ht { deny all; }
    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
EOF

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/elendil.K10.com
ln -s /etc/nginx/sites-available/elendil.K10.com /etc/nginx/sites-enabled/

chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage
chown -R www-data:www-data /var/www/laravel-simple-rest-api/bootstrap/cache

service php8.4-fpm restart
service nginx restart

# in worker (Isildur)
cat <<EOF > /etc/nginx/sites-available/isildur.K10.com
server {
    listen 8002;
    server_name isildur.K10.com elros.K10.com;
    root /var/www/laravel-simple-rest-api/public;
    index index.php;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    location ~ /\.ht { deny all; }
    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
EOF

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/isildur.K10.com
ln -s /etc/nginx/sites-available/isildur.K10.com /etc/nginx/sites-enabled/

chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage
chown -R www-data:www-data /var/www/laravel-simple-rest-api/bootstrap/cache

service php8.4-fpm restart
service nginx restart

# in worker (Anarion)
cat <<EOF > /etc/nginx/sites-available/anarion.K10.com
server {
    listen 8003;
    server_name anarion.K10.com elros.K10.com;
    root /var/www/laravel-simple-rest-api/public;
    index index.php;
    location / { try_files \$uri \$uri/ /index.php?\$query_string; }
    location ~ \.php\$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.4-fpm.sock;
    }
    location ~ /\.ht { deny all; }
    error_log /var/log/nginx/laravel_error.log;
    access_log /var/log/nginx/laravel_access.log;
}
EOF

rm -f /etc/nginx/sites-enabled/default
rm -f /etc/nginx/sites-enabled/anarion.K10.com
ln -s /etc/nginx/sites-available/anarion.K10.com /etc/nginx/sites-enabled/

chown -R www-data:www-data /var/www/laravel-simple-rest-api/storage
chown -R www-data:www-data /var/www/laravel-simple-rest-api/bootstrap/cache

service php8.4-fpm restart
service nginx restart

# in Elendil
cd /var/www/laravel-simple-rest-api

php artisan config:clear

php artisan key:generate
php artisan migrate:fresh
php artisan db:seed --class=AiringsTableSeeder

# chown -R www-data:www-data .
# chmod -R 775 storage bootstrap/cache