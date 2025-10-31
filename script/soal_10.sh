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

log_format upstream_custom '\$remote_addr - \$remote_user [\$time_local] '
                             '"\$request" \$status \$body_bytes_sent '
                             '"\$http_referer" "\$http_user_agent" '
                             'upstream="\$upstream_addr"';

upstream kesatria_numenor {
    server 192.216.1.2:8001;  # Elendil
    server 192.216.1.3:8002;  # Isildur
    server 192.216.1.4:8003;  # Anarion
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

ln -s /etc/nginx/sites-available/elros.K10.com /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

nginx -t
service nginx restart

# Amandil dan Gilgalad
curl http://elros.K10.com
curl http://elros.K10.com/api/airing

# Tes
# in Amandil
# Perintah ini akan memanggil API Elros sebanyak 12 kali
for i in {1..12}; do curl -s -o /dev/null http://elros.K10.com/api/airing; done

# in Elros
tail -n 100 /var/log/nginx/elros_access.log | grep "upstream" | sort | uniq -c
cat /var/log/nginx/elros_access.log

# Expected Output:
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.4:8003"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.2:8001"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.3:8002"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.4:8003"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.2:8001"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.3:8002"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.4:8003"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.2:8001"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.3:8002"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.4:8003"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.2:8001"
192.216.1.8 - - [01/Nov/2025:04:48:21 +0000] "GET /api/airing HTTP/1.1" 200 826 "-" "curl/8.14.1" upstream="192.216.1.3:8002"