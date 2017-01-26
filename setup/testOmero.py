#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
import sys
sys.path.insert(0, "/OMERO/OMERO.server/lib/python")

import omero.gateway
from omero.gateway import BlitzGateway

# =================================================================
# Main
# =================================================================
if __name__ == "__main__":
    try:
        HOST        = 'localhost'
        USER        = 'public_data'
        GROUP       = 'Public'
        PASSWORD    = 'public_data'
        PORT        = '4064'

        conn = BlitzGateway(USER, PASSWORD, host=HOST, port=PORT)
        if not conn.connect():
            sys.stderr.write("Server connection error")
            sys.exit(1)

        for g in conn.getGroupsMemberOf():
            if g.getName() == GROUP:
                break

        conn.SERVICE_OPTS.setOmeroGroup(g.getId())

        user = conn.getUser()
        print "Current user:"
        print "   ID:", user.getId()
        print "   Username:", user.getName()
        print "   Full Name:", user.getFullName()

        for p in conn.listProjects():
            print GROUP, p.getId(), p.getName()

    finally:
        conn.seppuku()

