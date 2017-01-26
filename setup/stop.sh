#!/bin/sh

echo Stopping PostgreSQL.
/usr/sbin/service postgresql stop

echo Stopping OMERO.
/usr/sbin/service omero stop

echo Stopping Nginx.
/usr/sbin/service nginx stop
