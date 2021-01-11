#!/bin/sh
exec /usr/bin/crunch-run -container-enable-networking=default -container-network-mode=host ${@}
