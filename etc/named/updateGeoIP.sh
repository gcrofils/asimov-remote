#!/bin/bash
# Shell Script to Update GeoIP Country database in each WebServer Jail defined by $TDIRS
# -------------------------------------------------------------------------
# Copyright (c) 2007 Vivek Gite <vivek@nixcraft.com>
# This script is licensed under GNU GPL version 2.0 or above
# -------------------------------------------------------------------------
# This script is part of nixCraft shell script collection (NSSC)
# Visit http://bash.cyberciti.biz/ for more information.
# -------------------------------------------------------------------------
GEOUPDATE=/usr/local/bin/geoipupdate
GEODB=/usr/local/share/GeoIP/GeoIP.dat
# ------------------
# TRUE = Update in Jail
# FALSE = Update only at $GEODB
CHROOTED=FALSE
# ------------------
# DIR:user:group format, only used if CHROOTED == TRUE
TDIRS="/webroot/apache/usr/local/geoip|www:www /webroot/nginix/usr/local/geoip|ngnix:ngnix"
CHOWN=/bin/chown
CP=/bin/cp
 
[ -f $GEOUPDATE ] && $GEOUPDATE
 
# Update if chrooted Apache jail...
if [ "$CHROOTED" == "TRUE" ]
then
 for i in $TDIRS
 do
	d=$(echo "$i" | cut -d'|' -f1)
	p=$(echo "$i" | cut -d'|' -f2)
	$CP -f $GEODB $d
	$CHOWN $p $d/$(basename $GEODB)
 done
fi