#!/bin/bash

# in Amandil
apt-get update
apt-get install -y lynx curl

# Tes koneksi ke Elendil, Isildur, Anarion
lynx http://elendil.K10.com:8001

lynx http://isildur.K10.com:8002

lynx http://anarion.K10.com:8003

# Tes API
curl http://elendil.K10.com:8001/api/airing

curl http://isildur.K10.com:8002/api/airing

curl http://anarion.K10.com:8003/api/airing