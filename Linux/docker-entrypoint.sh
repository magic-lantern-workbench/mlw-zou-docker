#!/bin/bash
set -e

echo "Waiting for database..."

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

# Seed initial data if needed
if zou init-data; then
    echo "init-data succeeded"
else
    echo "zou init-data failed" >&2
fi

exec gunicorn \
    --workers 4 \
    --bind 0.0.0.0:5000 \
    "zou.app:app"
