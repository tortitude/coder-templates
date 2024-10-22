#!/usr/bin/env bash

cp '${REPO_DIR}/packages/server/.env.example' '${REPO_DIR}/packages/server/.env'

%{ for key, value in SERVER_REWRITES ~}
sed -i 's|${key}=.*|${key}="${value}"|' '${REPO_DIR}/packages/server/.env'
%{ endfor ~}

echo 'VUE_ALLOWED_HOSTS=all' >> '${REPO_DIR}/packages/client/.env'
