#!/bin/sh

DATE=`date '+%Y%m%d_%H%M%S'`
OUTPUT_DIRECTORY=/postgres
DATABASE="omero_database"
DATABASE_ADMIN="postgres"

pg_dump -Fc -f $OUTPUT_DIRECTORY/$DATE"_"$DATABASE.pg_dump $DATABASE
#pg_restore -Fc -d $DATABASE $OUTPUT_DIRECTORY/$DATE"_"$DATABASE.pg_dump