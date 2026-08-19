#!/bin/bash
set -e

echo "Waiting for database..."

action_api_target="${KITSU_API_TARGET:-http://localhost:5000}"
action_event_target="${KITSU_EVENT_TARGET:-http://localhost:5000}"

# Kitsu proxies /api and /socket.io to the backend root. Do not append /api to
# the target URL here; Vite already strips the prefix during the rewrite.
# Keeping the backend target as http://localhost:5000 preserves the expected
# /config and /socket.io routes when the frontend is started with:
#   KITSU_API_TARGET=http://localhost:5000
#   KITSU_EVENT_TARGET=http://localhost:5000

echo "KITSU_API_TARGET=${action_api_target}"
echo "KITSU_EVENT_TARGET=${action_event_target}"

until zou is-db-ready
do
    if zou init-db; then
        echo "init-db succeeded"
        break
    else
        echo "zou init-db failed; retrying in 5s..." >&2
    fi
    sleep 5
done

# Seed initial data: retry until it succeeds (ensures app doesn't start without required seed data)
until zou init-data; do
    echo "zou init-data failed; retrying in 5s..." >&2
    sleep 5
done

echo "init-data succeeded"

# The Kitsu frontend calls the backend through /api and /socket.io; the backend
# itself stays on the root routes (/config, /auth, /data, etc.) and is served via
# the main Gunicorn process on :5000.
exec gunicorn \
    --workers 4 \
    --bind 0.0.0.0:5000 \
    "zou.app:app"
