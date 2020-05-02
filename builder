#!/bin/bash

# Wrapper script for docker-compose build

[ ! -e "docker-compose.yml" ] && echo "This script should be run from the arvados-compose directory" && exit 1
[ ${#} -ne 0 ] && IMAGES_TO_BUILD="${@}"

source .env

COMPOSE_DOCKER_CLI_BUILD=1 DOCKER_BUILDKIT=1 docker-compose --file docker-compose-build.yml --log-level DEBUG build ${IMAGES_TO_BUILD}

