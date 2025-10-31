#!/bin/bash
# in Elros
cat <<EOF > /etc/resolv.conf
nameserver 192.216.3.2
nameserver 192.216.3.3
nameserver 192.168.221.1
EOF

echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

apt-get update
apt-get install -y nginx

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

    access_log /var/log/nginx/elros_access.log;
    error_log /var/log/nginx/elros_error.log;
}
EOF

ln -s /etc/nginx/sites-available/elros.K10.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
service nginx restart

# Amandil dan Gilgalad
lynx http://elros.K10.com
curl http://elros.K10.com/api/airing

# Tes
# in Amandil
# Perintah ini akan memanggil API Elros sebanyak 12 kali
for i in {1..12}; do
    curl -s http://elros.K10.com/api/airing > /dev/null
done

# in Elros
tail -n 100 /var/log/nginx/elros_access.log | grep "upstream" | sort | uniq -c

# Expected Output:
4 upstream="http://192.216.1.2:8001/api/airing"
4 upstream="http://192.216.1.3:8002/api/airing"
4 upstream="http://192.216.1.4:8003/api/airing"