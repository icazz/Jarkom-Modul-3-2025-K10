#!/bin/bash
# in Aldarion
cat <<EOF > /etc/dhcp/dhcpd.conf
# ==========================================================
#  Konfigurasi DHCP Server untuk Aldarion (Soal 2 & 6)
# ==========================================================

# --- Opsi Global ---
ddns-update-style none;
authoritative;
log-facility local7;

# PERBAIKAN: Menggunakan IP DNS yang benar (dari Soal 4)
option domain-name-servers 192.216.5.2;

# PERBAIKAN: Menerapkan max-lease-time dari Soal 6 (1 jam)
max-lease-time 3600; 

# ==========================================================
#  Subnet 1: Keluarga Manusia (untuk Amandil)
# ==========================================================
subnet 192.216.1.0 netmask 255.255.255.0 {
    option routers 192.216.1.1;
    
    # PERBAIKAN: Rentang IP dimulai dari .7 (menghindari Elros .6)
    range 192.216.1.7 192.216.1.34;
    range 192.216.1.68 192.216.1.94;
    
    # PERBAIKAN: Menerapkan lease time Soal 6 (1/2 jam)
    default-lease-time 1800; 
}

# ==========================================================
#  Subnet 2: Keluarga Peri (untuk Gilgalad)
# ==========================================================
subnet 192.216.2.0 netmask 255.255.255.0 {
    option routers 192.216.2.1;
    range 192.216.2.35 192.216.2.67;
    range 192.216.2.96 192.216.2.121;
    
    # PERBAIKAN: Menerapkan lease time Soal 6 (1/6 jam)
    default-lease-time 600;
}

# ==========================================================
#  Subnet 3: (untuk Khamul)
# ==========================================================
subnet 192.216.3.0 netmask 255.255.255.0 {
    option routers 192.216.3.1;
    # Tidak ada rentang dinamis, hanya host tetap
}

# ==========================================================
#  Subnet 4: Lokasi Server (Aldarion)
# ==========================================================
# PERBAIKAN: Hanya perlu satu deklarasi kosong agar servis menyala
subnet 192.216.4.0 netmask 255.255.255.0 {
}

# ==========================================================
#  Host Tetap: Khamul
# ==========================================================
host Khamul {
    hardware ethernet 02:42:9c:bc:cc:00;
    fixed-address 192.216.3.95;
}
EOF

# Cek
# in Amandil/Gilgalad
dhclient -r
dhclient eth0
# in Aldarion
cat /var/lib/dhcp/dhcpd.leases

# Ekspektasi
# lease 192.216.1.7 {
#   starts 5 2025/10/29 08:10:00;
#   ends 5 2025/10/29 08:40:00;  <-- Perhatikan ini harus 1800 detik/30 menit
#   ...
# }