#!/usr/bin/env bash

SYNC_DIR="$( cd $(dirname $0) && cd ../ && pwd -L )"
WORK_HEAD_FILE="${SYNC_DIR}/WORK_HEAD"
LOCK_DIR="${SYNC_DIR}/lock.d"
WORK_BRANCH="work"

CURRENT_WORK_HEAD="$(cat "$WORK_HEAD_FILE")"

die() {
  echo "$1" >&2
  exit 1
}

checkout() {
  git sync lock
  local ref=
  if [ "$1" = "-b" ]; then
    ref="$CURRENT_WORK_HEAD"
    shift
    git branch "$1" "$ref"
  else
    ref="$(git rev-parse --symbolic-full-name "$1")"
    if [ -z "$ref" ]; then
      git sync unlock
      die "ref \"$1\" not found"
    fi
    git checkout "${ref#refs/heads/}" # ensure local branch exists
    ref="$(git rev-parse --symbolic-full-name HEAD)"
  fi
  git checkout "$WORK_BRANCH"
  git reset --hard "$ref"
  echo "$ref" > "$WORK_HEAD_FILE"
  git sync unlock
  echo "working-on: $(git sync working-on)"
}

case "$1" in
  lock)
    mkdir "${LOCK_DIR}" || die "unable to acquire lock (lock.dir: ${LOCK_DIR})"
  ;;
  unlock)
    rmdir "${LOCK_DIR}"
  ;;
  checkout)
    shift
    checkout "${@}"
  ;;
  working-on)
    echo "${CURRENT_WORK_HEAD}"
  ;;
  *)
    echo "unrecognized options: $1" >&2
    exit 1
  ;;
esac
