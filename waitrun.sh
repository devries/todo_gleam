#!/bin/sh

if [ -n "${SIGNAL_FILE+1}" ]; then
  until [ -f "${SIGNAL_FILE}" ]; do
    echo "Waiting for ${SIGNAL_FILE}..."
    sleep 5
  done
fi
echo "Starting server"
exec /app/entrypoint.sh run
