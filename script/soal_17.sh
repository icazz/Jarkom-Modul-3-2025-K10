#!/bin/bash
# ==========================================================
# Uji Serangan ke Pharazon dan Simulasi Kegagalan
# ==========================================================

echo "--- BAGIAN 1: Uji Distribusi Beban Awal (Di Amandil/Gilgalad) ---"
# in Amandil/Gilgalad (Pastikan apache2-utils terinstal)

# Serangan untuk mengamati distribusi beban (12 requests, 3 concurrent)
ab -n 12 -c 3 -A noldor:silvan http://pharazon.K10.com/

echo "Cek log Pharazon untuk melihat distribusi (tail -n 20 /var/log/nginx/access.log)"


echo "--- BAGIAN 2: Simulasi Taman Runtuh (Galadriel) ---"
# in Galadriel
echo "Menghentikan Nginx di Galadriel untuk simulasi runtuh..."
# service nginx stop

echo "--- Ulangi Uji Beban setelah Galadriel Down (Di Amandil/Gilgalad) ---"
# in Amandil/Gilgalad
ab -n 12 -c 3 -A noldor:silvan http://pharazon.K10.com/

echo "--- VERIFIKASI ---"
echo "Cek Log Pharazon untuk memastikan Galadriel tidak lagi mendapat request"
# in Pharazon
# tail -n 20 /var/log/nginx/access.log 
# cat /var/log/nginx/error.log