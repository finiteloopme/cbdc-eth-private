#!/bin/bash
set -euxo pipefail
echo "Starting Blockscout script"

# Pod 0 is responsible for initializing the database.
if [[ "${HOSTNAME##*-}" -eq "0" ]] &&
   [[ ! -e /opt/blockscout-data/db_initialized ]]
then
  echo "Initializing database"
  mix do ecto.drop
  mix do ecto.create
  mix do ecto.migrate
  touch /opt/blockscout-data/db_initialized
fi

# An SSL certificate is required to start the server.
pushd apps/block_scout_web
mix phx.gen.cert localhost
popd

# Run Blockscout.
mix phx.server