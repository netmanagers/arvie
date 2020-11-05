#!/bin/bash

# Wrapper script for docker-compose build

[ ! -e "docker-compose.yml" ] && echo "This script must be run from the arvie directory" && exit 1

usage() {
  echo >&2
  echo >&2 "Usage: $0 [-h] [-n] <IMAGE>"
  echo >&2
  echo >&2 "$0 options:"
  echo >&2 "  -n, --no-cache        Don't recreate the gem/pip/npm cache before building any image"
  echo >&2 "  -h, --help            Display this help and exit"
  echo >&2 "  <IMAGE>               Image to build/rebuild. Defaults to all of them"
  echo >&2
}

arguments() {
  # NOTE: This requires GNU getopt (part of the util-linux package on Debian-based distros).
  TEMP=`getopt -o hn \
    --long help,no-cache \
    -n "$0" -- "$@"`

  if [ $? != 0 ] ; then usage; exit 1 ; fi

  # Note the quotes around '$TEMP': they are essential!
  eval set -- "$TEMP"

  while [ $# -ge 1 ]; do
    case $1 in
      -n | --no-cache)
        CACHE="no"
        shift
        ;;
      --)
        shift
        break
        ;;
      *)
        usage
        exit 0
        ;;
    esac
  done

  IMAGES_TO_BUILD=$@
}

IMAGES_TO_BUILD=""
CACHE="yes"

arguments $@

source .env

if [ "x${CACHE}" = "xyes" ]; then
  # Create the cache dirs to speed up later runs
  echo "Building the NPM, Ruby gems and Golang caches"
  mkdir -p ${HOST_GEMCACHE} ${HOST_GOCACHE} ${HOST_PIPCACHE} ${HOST_NPMCACHE} ${HOST_RLIBS}
  COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-cache-builder.yml up --remove-orphans  gem-cache
  echo "Tearing down the cache images"
  docker-compose --file docker-compose-cache-builder.yml down
fi

echo "Building images"
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-build.yml --log-level DEBUG build ${IMAGES_TO_BUILD}
