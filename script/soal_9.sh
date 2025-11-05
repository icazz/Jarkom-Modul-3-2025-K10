#!/bin/bash

# in Amandil
apt-get update
apt-get install -y lynx curl

# Tes koneksi ke Elendil, Isildur, Anarion (berhasil)
lynx http://elendil.K10.com:8001

lynx http://isildur.K10.com:8002

lynx http://anarion.K10.com:8003

# Tes API (berhasil)
curl http://elendil.K10.com:8001/api/airing

curl http://isildur.K10.com:8002/api/airing

curl http://anarion.K10.com:8003/api/airing

# Tes koneksi ke Elendil, Isildur, Anarion (gagal)
lynx http://192.216.1.2:8001
lynx http://192.216.1.3:8002
lynx http://192.216.1.4:8003

# Tes API (gagal)
curl http://192.216.1.2:8001/api/airing
curl http://192.216.1.3:8002/api/airing
curl http://192.216.1.4:8003/api/airing