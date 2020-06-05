#!/bin/bash

# Wrapper script for docker-compose build

[ ! -e "docker-compose.yml" ] && echo "This script should be run from the arvados-compose directory" && exit 1
[ ${#} -ne 0 ] && IMAGES_TO_BUILD="${@}"

source .env

echo "Building the NPM, Ruby gems and Golang caches"
# Create the cache dirs to speed up later runs
mkdir -p ${HOST_GEMCACHE} ${HOST_GOCACHE} ${HOST_PIPCACHE} ${HOST_NPMCACHE} ${HOST_RLIBS}
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-cache-builder.yml up --remove-orphans  gem-cache
docker-compose --file docker-compose-cache-builder.yml down


COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-build.yml --log-level DEBUG build ${IMAGES_TO_BUILD}
