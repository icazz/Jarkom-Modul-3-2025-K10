#!/bin/bash

# in Aldarion (DHCP Server)
# Aldarion (DHCP Server)
cat <<EOF > /root/.bashrc
apt-get update
apt-get install -y isc-dhcp-server
EOF

# Memberi tahu isc-dhcp-server agar "mendengarkan" di eth0
cat <<EOF > /etc/default/isc-dhcp-server
INTERFACESv4="eth0"
INTERFACESv6=""
EOF

# Konfigurasi Utama DHCP
cat <<EOF > /etc/dhcp/dhcpd.conf

ddns-update-style none;
authoritative;
log-facility local7;

default-lease-time 600;
max-lease-time 7200;

# --- Subnet 1: Keluarga Manusia (Amandil) ---
subnet 192.216.1.0 netmask 255.255.255.0 {
    range 192.216.1.6 192.216.1.34; # ke dobel sama ip-nya elros(1.6)
    range 192.216.1.68 192.216.1.94;
    option routers 192.216.1.1;
    option broadcast-address 192.216.1.255;
    option domain-name-servers 192.216.3.2, 192.216.3.3, 192.168.122.1;
}

# --- Subnet 2: Keluarga Peri (Gilgalad) ---
subnet 192.216.2.0 netmask 255.255.255.0 {
    range 192.216.2.35 192.216.2.67;
    range 192.216.2.96 192.216.2.121;
    option routers 192.216.2.1;
    option broadcast-address 192.216.2.255;
    option domain-name-servers 192.216.3.2, 192.216.3.3, 192.168.122.1;
}


# ========================
#  SUBNET 3 - KURCACI khamul
# ========================
subnet 192.216.3.0 netmask 255.255.255.0 {
    option routers 192.216.3.1;
    option broadcast-address 192.216.3.255;
}

# ========================
#  SUBNET 4 - DATABASE
# ========================
subnet 192.216.4.0 netmask 255.255.255.0 {
    option routers 192.216.4.1;
    option broadcast-address 192.216.4.255;
}

# ========================
#  SUBNET 5 - PROXY
# ========================
subnet 192.216.5.0 netmask 255.255.255.0 {
    option routers 192.216.5.1;
    option broadcast-address 192.216.5.255;
}

# --- PERBAIKAN: Subnet 4 (Tempat Aldarion Berada) ---
# Wajib ada agar servis bisa menyala
subnet 192.216.4.0 netmask 255.255.255.0 {
}

host Khamul {
    hardware ethernet 02:42:9c:bc:cc:00;
    fixed-address 192.216.3.95;
}
EOF

service isc-dhcp-server restart

# in Durin (DHCP Relay)
cat <<EOF > /root/.bashrc
apt-get update
apt-get install -y isc-dhcp-relay
EOF

cat <<EOF > /etc/default/isc-dhcp-relay
SERVERS="192.216.4.2"
INTERFACES="eth1 eth2 eth3 eth4 eth5"
EOF

# Konfigurasi IP Forwarding (mengaktifkan IP Forwarding)
cat <<EOF > /etc/sysctl.conf
net.ipv4.ip_forward=1
EOF

sysctl -p
service isc-dhcp-relay restart

# Jalankan ip a di setiap client:
# Amandil harus mendapatkan IP di rentang 192.216.1.6 - .34 atau 192.216.1.68 - .94.
# Gilgalad harus mendapatkan IP di rentang 192.216.2.35 - .67 atau 192.216.2.96 - .121.
# Khamul harus mendapatkan IP tepat 192.216.3.95.