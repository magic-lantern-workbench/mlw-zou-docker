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

# 'zou is-db-ready' exits 0 even when the schema is missing, so always run
# init-db (idempotent) and retry until it succeeds.
until zou init-db
do
    echo "zou init-db failed; retrying in 5s..." >&2
    sleep 5
done
echo "init-db succeeded"

# Seed initial data: retry until it succeeds (ensures app doesn't start without required seed data)
until zou init-data; do
    echo "zou init-data failed; retrying in 5s..." >&2
    sleep 5
done

echo "init-data succeeded"

# The Kitsu frontend calls the backend through /api and /socket.io; the backend
# itself stays on the root routes (/config, /auth, /data, etc.). Run a
# small event server for socket.io on port 5001 and expose it to the host.

echo "Starting event server on 0.0.0.0:5001"
# Run the event server in the background (gevent worker). It must be reachable
# from the host at port 5001; docker-compose maps it to the host.
nohup gunicorn --worker-class geventwebsocket.gunicorn.workers.GeventWebSocketWorker \
    -b 0.0.0.0:5001 -w 1 zou.event_stream:app > /proc/1/fd/1 2>/proc/1/fd/2 &

# Start main API server
exec gunicorn \
    --workers 4 \
    --bind 0.0.0.0:5000 \
    "zou.app:app"
