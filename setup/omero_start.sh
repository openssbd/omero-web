#!/bin/sh

/OMERO/OMERO.server/bin/omero admin start
sleep 3
/OMERO/OMERO.server/bin/omero web start
echo "Started OMERO"
