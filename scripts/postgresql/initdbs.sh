#!/bin/bash
set -e

# We create the arvados user as superuser. Sucks, but the rake task to setup
# the database needs this permission to add the trgm extension
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  CREATE USER arvados_vwxyz WITH ENCRYPTED PASSWORD 'arvados_vwxyz' CREATEDB SUPERUSER;
EOSQL
