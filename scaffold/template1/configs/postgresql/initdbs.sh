#!/bin/bash
set -e

# FIXME! Perhaps this belongs to the api init script?

# We create the arvados user as superuser. Sucks, but the rake task to setup
# the database needs this permission to add the trgm extension
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER arvados___CLUSTER__ WITH ENCRYPTED PASSWORD 'arvados___CLUSTER__' CREATEDB SUPERUSER;
EOSQL
