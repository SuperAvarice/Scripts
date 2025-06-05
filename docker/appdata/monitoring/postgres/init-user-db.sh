#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE USER asdf;
    CREATE DATABASE asdf;
    GRANT ALL PRIVILEGES ON DATABASE asdf TO asdf;
    CREATE USER postgres;
EOSQL
