#!/usr/bin/env bash

REMOTE_URL=$(git config --get remote.origin.url)
SSH_CONNECT="${REMOTE_URL%:*}"
REMOTE_PATH="${REMOTE_URL#*:}"
REMOTE_UPDATE_SCRIPT="./.git/server-sync/server/update.sh"

if [ -z "$SSH_CONNECT" ]; then
  ( cd "$REMOTE_PATH" && "$REMOTE_UPDATE_SCRIPT" "${@}" )
else
  ssh "$SSH_CONNECT" "cd "$REMOTE_PATH" && "$REMOTE_UPDATE_SCRIPT" "${@}"" 
fi

REMOTE_WORK_BRANCH="origin/work"
BACKUP_TAG="work_backup"
git fetch --all
git tag -d "$BACKUP_TAG"
git tag "$BACKUP_TAG"
git reset --keep "$REMOTE_WORK_BRANCH"
