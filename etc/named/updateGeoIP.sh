#!/bin/bash
cd /tmp
wget "http://geolite.maxmind.com/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz"
rm -f GeoIP.dat
gunzip GeoIP.dat.gz
mv -f GeoIP.dat /usr/local/share/GeoIP
