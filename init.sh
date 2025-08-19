#!/usr/bin/env bash
set -euo pipefail

echo "[init] running Superset DB migrations..."
superset db upgrade

# Create admin user if not exists (ignore error if already exists)
echo "[init] ensuring admin user exists..."
superset fab create-admin       --username "${ADMIN_USERNAME:-admin}"       --firstname "${ADMIN_FIRST_NAME:-Superset}"       --lastname "${ADMIN_LAST_NAME:-Admin}"       --email "${ADMIN_EMAIL:-admin@example.com}"       --password "${ADMIN_PASSWORD:-admin}" || true

# Optionally load examples
if [ "${LOAD_EXAMPLES:-false}" = "true" ]; then
  echo "[init] loading example data..."
  superset load_examples || true
fi

echo "[init] initializing roles & perms..."
superset init

echo "[init] done."
