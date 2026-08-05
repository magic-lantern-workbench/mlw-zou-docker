#!/bin/bash
set -e

echo "Waiting for database..."

until zou is-db-ready >/dev/null 2>&1
do
    if zou init-db >/dev/null 2>&1; then
        break
    fi
    sleep 5
done

exec gunicorn \
    --workers 4 \
    --bind 0.0.0.0:5000 \
    "zou.app:app"
