#!/bin/bash

echo Starting PostgreSQL.
/usr/sbin/service postgresql start

echo Starting OMERO.
/usr/sbin/service omero start

echo Starting Nginx.
/usr/sbin/service nginx start
