#!/usr/bin/env bash

SYNC_DIR=$( cd $(dirname $0) && pwd -L )

(

cd "$SYNC_DIR/../"

case "$1" in
  server)
    echo "configure for server"
    git config receive.denyCurrentBranch ignore
  ;;
  client)
    echo "configure for client"
    git config alias.sync "${GIT_DIR:-./.git}/sync/client/sync.sh"
  ;;
  *)
    echo "unrecognized option: $1" >&2
  ;;
esac

)
