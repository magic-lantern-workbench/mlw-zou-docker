#!/bin/bash
set -e

echo "Waiting for database..."

until zou is-db-ready
do
    if zou init-db; then
        break
    else
        echo "zou init-db failed; retrying in 5s..." >&2
    fi
    sleep 5
done

exec gunicorn \
    --workers 4 \
    --bind 0.0.0.0:5000 \
    "zou.app:app"
