#!/bin/ash
/usr/sbin/unbound-anchor -a /opt/root.key -c /opt/icannbundle.pem -r /opt/root.hints
