#!/usr/bin/env bash

# NOTE: If a db already exist, its "psql create database" command will fail; that's ok!
psql -c "alter user \"${PGUSER}\" with password '${PGPASSWORD}'"

%{ for dbname in DB_NAMES ~}
psql -c "create database \"${dbname}\""
%{ endfor ~}
