#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE DATABASE development;
    CREATE DATABASE test;
    GRANT ALL PRIVILEGES ON DATABASE development TO postgres;
    GRANT ALL PRIVILEGES ON DATABASE test TO postgres;
EOSQL
