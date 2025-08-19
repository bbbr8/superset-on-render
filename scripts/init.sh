#!/usr/bin/env bash
set -euo pipefail

# Run DB migrations
python -m superset db upgrade

# Create admin user if not exists (ignore error if already exists)
echo "[init] ensuring admin user exists..."
python -m superset fab create-admin \
  --username "${ADMIN_USERNAME:-admin}" \
  --firstname "${ADMIN_FIRST_NAME:-Superset}" \
  --lastname "${ADMIN_LAST_NAME:-Admin}" \
  --email "${ADMIN_EMAIL:-admin@example.com}" \
  --password "${ADMIN_PASSWORD:-admin}"

# Optionally load examples
if [ "${LOAD_EXAMPLES:-false}" = "true" ]; then
  echo "[init] loading example data..."
  python -m superset load_examples || true
fi

# Initialize roles and permissions
echo "[init] initializing roles & perms..."
python -m superset init

echo "[init] done."
