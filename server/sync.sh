#!/usr/bin/env bash

SYNC_DIR=$( cd $(dirname $0) && pwd -L )
LOCK_DIR="${SYNC_DIR}/lock.d"

die() {
  echo "$1" >&2
  exit 1
}

case "$1" in
   lock)
     mkdir "${LOCK_DIR}" || die "unable to acquire lock (lock.dir: ${LOCK_DIR})"
   ;;
   unlock)
     rmdir "${LOCK_DIR}"
   ;;
   *)
     echo "unrecognized options: $1" >&2
     exit 1
   ;;
esac
