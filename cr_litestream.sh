#!/bin/sh
# set -e # Exit immediately if a command exits with non-zero status

echo "Attempting restore from $REPLICA_URL to $DBFILE..."
litestream restore -if-replica-exists -o "$DBFILE" "$REPLICA_URL"
touch $SIGNAL_FILE

echo "Restore attempt finished. Starting replication..."

exec litestream replicate "$DBFILE" "$REPLICA_URL"
