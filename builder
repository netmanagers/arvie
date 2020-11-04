#!/bin/bash

# Wrapper script for docker-compose build

[ ! -e "docker-compose.yml" ] && echo "This script should be run from the arvados-compose directory" && exit 1
[ ${#} -ne 0 ] && IMAGES_TO_BUILD="${@}"

source .env

echo "Building the NPM, Ruby gems and Golang caches"
# Create the cache dirs to speed up later runs
mkdir -p ${HOST_GEMCACHE} ${HOST_GOCACHE} ${HOST_PIPCACHE} ${HOST_NPMCACHE} ${HOST_RLIBS}
echo "Creating the GEMS cache"
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-cache-builder.yml up --remove-orphans  gem-cache
echo "Tearing down the cache images"
docker-compose --file docker-compose-cache-builder.yml down
echo "Building images"
COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-build.yml --log-level DEBUG build ${IMAGES_TO_BUILD}
