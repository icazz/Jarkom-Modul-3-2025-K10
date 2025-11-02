#!/bin/bash

echo "Logika untuk menampilkan IP Pengunjung Asli sudah dimasukkan"
echo "ke dalam file /var/www/html/index.php pada Soal 12/13:"
echo '<?php echo "<p>Alamat IP Pengunjung: " . ($_SERVER['\''HTTP_X_REAL_IP'\''] ?? $_SERVER['\''REMOTE_ADDR'\'']) . "</p>"; ?>'
echo "Header X-Real-IP akan diset oleh Load Balancer Pharazon (Soal 16)."

# --- Verifikasi di Client (Hanya akan menunjukkan IP klien saat ini) ---
# in Amandil/Gilgalad
# curl -u noldor:silvan http://galadriel.K10.com:8004/