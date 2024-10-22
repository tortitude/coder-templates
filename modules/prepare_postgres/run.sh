#!/usr/bin/env bash
export PGUSER="${PGUSER}"
PGPASSWORD="${PGPASSWORD}"

psql -c "alter user \"${PGUSER}\" with password '$PGPASSWORD'"

# NOTE: If a db already exist, its "psql create database" command will fail; that's ok!
%{ for DBNAME in DB_NAMES ~}
DBNAME="${DBNAME}"
psql -c "create database \"$DBNAME\" with owner \"$PGUSER\"" || echo "Database $DBNAME not created. Does it already exist?"
%{ endfor ~}
