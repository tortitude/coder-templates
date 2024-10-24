#!/usr/bin/env bash
export PGUSER="${PGUSER}"
PGPASSWORD="${PGPASSWORD}"

psql -c "alter user \"${PGUSER}\" with password '$PGPASSWORD'"

# NOTE: If a db already exist, its "psql create database" command will fail; that's ok!
%{ for DBNAME in DB_NAMES ~}
DBNAME="${DBNAME}"
if [ $(psql -XtAc "SELECT 1 FROM pg_database WHERE datname='$DBNAME'") != '1' ]; then
    echo "Creating database $DBNAME..."
    psql -c "create database \"$DBNAME\" with owner \"$PGUSER\""
else
    echo "Database $DBNAME already exists"
fi
%{ endfor ~}
