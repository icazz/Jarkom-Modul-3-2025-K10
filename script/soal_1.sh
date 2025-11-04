#!/bin/bash
# Rangkuman
# eth1    192.216.1.1
# eth2    192.216.2.1
# eth3    192.216.3.1
# eth4    192.216.4.1
# eth5    192.216.5.1

# Elendil     192.216.1.2
# Isildur     192.216.1.3
# Anarion     192.216.1.4
# Miriel      192.216.1.5
# Elros       192.216.1.6

# Galadriel   192.216.2.2
# Celeborn    192.216.2.3
# Oropher     192.216.2.4
# Celebrimbor 192.216.2.5
# Pharazon    192.216.2.6

# Erendis     192.216.3.2
# Amdir       192.216.3.3

# Aldarion    192.216.4.2
# Palantir    192.216.4.3
# Narvi       192.216.4.4

# Minastri    192.216.5.2

# Gilgalad    DHCP
# Amandil     DHCP
# Khamul      DHCP (fixed address)

# Durin (Router/DHCP Relay)

cat <<EOF > /etc/network/interfaces
# Interface ke NAT1 (Internet)
auto eth0
iface eth0 inet dhcp

# Interface ke Switch1 (Prefix 1.1)
auto eth1
iface eth1 inet static
    address 192.216.1.1
    netmask 255.255.255.0

# Interface ke Switch2 (Prefix 2.1)
auto eth2
iface eth2 inet static
    address 192.216.2.1
    netmask 255.255.255.0

# Interface ke Switch3 (Prefix 3.1)
auto eth3
iface eth3 inet static
    address 192.216.3.1
    netmask 255.255.255.0

# Interface ke Switch6 (Prefix 4.1)
auto eth4
iface eth4 inet static
    address 192.216.4.1
    netmask 255.255.255.0

# Interface ke Switch4 (Prefix 5.1)
auto eth5
iface eth5 inet static
    address 192.216.5.1
    netmask 255.255.255.0
EOF

cat <<EOF > /root/.bashrc
apt-get update
apt-get install -y iptables
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF

# Subnet 1 (Gateway 192.168.1.1)

# Elendil (Laravel Worker-1)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.1.2
    netmask 255.255.255.0
    gateway 192.216.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Isildur (Laravel Worker-2)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.1.3
    netmask 255.255.255.0
    gateway 192.216.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Anarion (Laravel Worker-3)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.1.4
    netmask 255.255.255.0
    gateway 192.216.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Miriel (Client-Static-1)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.1.5
    netmask 255.255.255.0
    gateway 192.216.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Elros (Load Balancer (Laravel))
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.1.6
    netmask 255.255.255.0
    gateway 192.216.1.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Subnet 2 (Gateway: 192.216.2.1)

# Galadriel (PHP Worker-1)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.2.2
    netmask 255.255.255.0
    gateway 192.216.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Celeborn (PHP Worker-2)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.2.3
    netmask 255.255.255.0
    gateway 192.216.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Oropher (PHP Worker-3)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.2.4
    netmask 255.255.255.0
    gateway 192.216.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Celebrimbor (Client-Static-2)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.2.5
    netmask 255.255.255.0
    gateway 192.216.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Pharazon (Load Balancer (PHP))
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.2.6
    netmask 255.255.255.0
    gateway 192.216.2.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Subnet 3 (Gateway: 192.216.3.1)

# Erendis (DNS Master)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.3.2
    netmask 255.255.255.0
    gateway 192.216.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Amdir (DNS Slave)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.3.3
    netmask 255.255.255.0
    gateway 192.216.3.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Subnet 4 (Gateway: 192.216.4.1)

# Aldarion (DHCP Server)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.4.2
    netmask 255.255.255.0
    gateway 192.216.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Palantir (Database Server)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.4.3
    netmask 255.255.255.0
    gateway 192.216.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Narvi (Database Slave)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.4.4
    netmask 255.255.255.0
    gateway 192.216.4.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Subnet 5 (Gateway: 192.216.5.1)

# Minastri (Forward Proxy)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.216.5.2
    netmask 255.255.255.0
    gateway 192.216.5.1
    up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Dinamis
# Gilgalad (Client-Dynamic-1)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Amandil (Client-Dynamic-2)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Khamul (Client-Fixed-Address)
cat <<EOF > /etc/network/interfaces
auto eth0
iface eth0 inet dhcp

up echo nameserver 192.168.122.1 > /etc/resolv.conf
EOF

# Note: jika dicoba, yang static bisa ping google dan dinamis tidak bisa
# Kenapa? karena static sudah ada ip(harus di beri saat config), sedangkan dinamis belum diberi ip
# Cara cek: Ping google pada setiap client
ping google.com -c 4