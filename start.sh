#!/usr/bin/env bash

# OSMOSIS tuning: https://wiki.openstreetmap.org/wiki/Osmosis/Tuning,https://lists.openstreetmap.org/pipermail/talk/2012-October/064771.html
if [ -z "$MEMORY_JAVACMD_OPTIONS" ]; then
    echo JAVACMD_OPTIONS=\"-server\" > ~/.osmosis
else
    memory="${MEMORY_JAVACMD_OPTIONS//i}"
    echo JAVACMD_OPTIONS=\"-server -Xmx$memory\" > ~/.osmosis
fi
# Get the data
wget $URL_FILE_TO_IMPORT
file=$(basename $URL_FILE_TO_IMPORT)

function initializeDatabase() {
  cockroach sql --insecure \
  --host $POSTGRES_HOST \
  --execute "CREATE DATABASE IF NOT EXISTS $POSTGRES_DB"

  cockroach sql --insecure \
  --host $POSTGRES_HOST \
  --execute "SET CLUSTER SETTING sql.conn.max_read_buffer_message_size=64MiB"
}

function importData () {
  pbfFile=$file
  echo "Importing $pbfFile ..."
  osm2pgsql \
  -c $pbfFile \
  -H $POSTGRES_HOST \
  -P $POSTGRES_PORT \
  -d $POSTGRES_DB \
  -U $POSTGRES_USER
}

flag=true
while "$flag" = true; do
    pg_isready -h $POSTGRES_HOST -p 26257 -U $POSTGRES_USER >/dev/null 2>&2 || continue
    # Change flag to false to stop ping the DB
    flag=false
    initializeDatabase
    importData
done
