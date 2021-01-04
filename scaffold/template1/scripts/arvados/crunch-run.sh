#!/bin/sh
# FIXME!
# Not sure if the networking parameters are correct for Arvie
# Also, they should be configurable
# exec /usr/local/bin/crunch-run -container-enable-networking=default -container-network-mode=host \$@
exec /usr/local/bin/crunch-run \$@
