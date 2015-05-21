#!/usr/bin/env bash

die() {
  echo "$1" >&2
  exit 1
}

case "$1" in
   update)
     # pass through to server update script
     shift
   ;;
   '')
     git commit -am 'sync auto-message' || die "sync auto-commit failed"
     git push || die "sync auto-push failed"
     exit
   ;;
   *)
     echo "unrecognized options: $1" >&2
     exit 1
   ;;
esac

REMOTE_URL=$(git config --get remote.origin.url)
SSH_CONNECT="${REMOTE_URL%:*}"
REMOTE_PATH="${REMOTE_URL#*:}"
REMOTE_UPDATE_SCRIPT="sync/server/update.sh"

if [ -z "$SSH_CONNECT" ]; then
  ( cd "$REMOTE_PATH" && "${GIT_DIR:-./.git}/$REMOTE_UPDATE_SCRIPT" "${@}" ) || die "local remote command failed"
else
  ssh "$SSH_CONNECT" "cd "$REMOTE_PATH" && "\${GIT_DIR:-./.git}/$REMOTE_UPDATE_SCRIPT" "${@}"" || die "remote command failed"
fi

REMOTE_WORK_BRANCH="origin/work"
BACKUP_TAG="work_backup"
git fetch --all || die "client fetch command failed"
git tag -d "$BACKUP_TAG"
git tag "$BACKUP_TAG"
git reset --keep "$REMOTE_WORK_BRANCH" || die "client \"reset --keep\" command failed"
