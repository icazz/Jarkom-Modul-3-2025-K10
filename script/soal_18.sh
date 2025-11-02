#!/bin/bash
# ==========================================================
# Replikasi Database (Palantir Master - Narvi Slave)
# ==========================================================

# --- BAGIAN 1: Konfigurasi Palantir (Master) ---
echo "--- BAGIAN 1: Konfigurasi Palantir (Master) ---"
# in Palantir

# Aktifkan binlog dan atur server-id
if ! grep -q "log-bin" /etc/mysql/mariadb.conf.d/50-server.cnf; then
    sed -i '/\[mariadb\]/a log-bin=mysql-bin\nserver-id=1\nbinlog_do_db=laravel_db' /etc/mysql/mariadb.conf.d/50-server.cnf
fi

service mariadb restart

echo "Membuat user replikasi dan mencatat status Master..."
mysql -u root <<MYSQL_SCRIPT
CREATE USER 'repl_user'@'192.216.4.4' IDENTIFIED BY 'replpassword';
GRANT REPLICATION SLAVE ON *.* TO 'repl_user'@'192.216.4.4';
FLUSH PRIVILEGES;

SHOW MASTER STATUS; 
# Catat 'File' dan 'Position' dari output di atas untuk digunakan di Narvi!
MYSQL_SCRIPT


# --- BAGIAN 2: Konfigurasi Narvi (Slave) ---
echo "--- BAGIAN 2: Konfigurasi Narvi (Slave) ---"
# in Narvi

# Instalasi MariaDB di Narvi (jika belum)
apt-get update
apt-get install -y mariadb-server

# Aktifkan read-only, atur server-id, dan bind-address
if ! grep -q "server-id" /etc/mysql/mariadb.conf.d/50-server.cnf; then
    sed -i '/\[mariadb\]/a server-id=2\nrelay-log=mysql-relay-bin\nread-only=1' /etc/mysql/mariadb.conf.d/50-server.cnf
fi
# Izinkan koneksi dari Palantir
sed -i "s/bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf

service mariadb restart

echo "Menghubungkan Narvi ke Master (Palantir)..."
# GANTI 'nama_file_binlog' dan 'posisi_binlog' dengan nilai dari Palantir!
# Gunakan nama file dan posisi dari output SHOW MASTER STATUS; di Palantir
MASTER_LOG_FILE="mysql-bin.000001" # Contoh, sesuaikan
MASTER_LOG_POS=760 # Contoh, sesuaikan

mysql -u root <<MYSQL_SCRIPT
CHANGE MASTER TO 
    MASTER_HOST='192.216.4.3', 
    MASTER_USER='repl_user', 
    MASTER_PASSWORD='replpassword', 
    MASTER_LOG_FILE='${MASTER_LOG_FILE}', 
    MASTER_LOG_POS=${MASTER_LOG_POS};

START SLAVE;
SHOW SLAVE STATUS\G
# Pastikan 'Slave_IO_Running' dan 'Slave_SQL_Running' bernilai 'Yes'
MYSQL_SCRIPT

echo "--- VERIFIKASI REPLIKASI ---"
echo "Langkah 1: Buat tabel di Palantir (Master)"
# in Palantir
# mysql -u root -e "USE laravel_db; CREATE TABLE IF NOT EXISTS test_replikasi (id INT PRIMARY KEY, nama VARCHAR(50));"

echo "Langkah 2: Cek di Narvi (Slave) - Tabel harus muncul"
# in Narvi
# mysql -u root -e "USE laravel_db; SHOW TABLES;"