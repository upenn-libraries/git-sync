#!/usr/bin/env bash

SYNC_DIR="$( cd $(dirname $0) && cd ../ && pwd -L )"
WORK_HEAD_FILE="${SYNC_DIR}/WORK_HEAD"
WORK_HEAD_FILE_REMOTE="${SYNC_DIR}/WORK_HEAD_REMOTE"

die() {
  echo "$1" >&2
  exit 1
}

record-working() {
  tee >(
    local working=$(grep -m 1 '^working-on: ' | cut -d ' ' -f 2)
    if [ -n "$working" ]; then
      echo "${working/heads/remotes/origin}" > "$WORK_HEAD_FILE_REMOTE"
    fi
  )
}

update-local() {
  REMOTE_WORK_BRANCH="$(git sync working-on --remote)"
  if [ "$1" != "--force" ]; then
    LOCAL_WORK_BRANCH="$(git sync working-on)"
    if [ "$LOCAL_WORK_BRANCH" != "$REMOTE_WORK_BRANCH" ]; then
      die "unexpected remote work branch ($REMOTE_WORK_BRANCH)! \
run \"git sync force-local-update\" \
to overwrite local work branch (for $LOCAL_WORK_BRANCH)"
    fi
  fi
  BACKUP_TAG="work_backup"
  git fetch --all || die "client fetch command failed"
  git tag -d "$BACKUP_TAG"
  git tag "$BACKUP_TAG"
  git reset --keep "$REMOTE_WORK_BRANCH" || die "client \"reset --keep\" command failed"
  echo "$REMOTE_WORK_BRANCH" > "$WORK_HEAD_FILE"
}

case "$1" in
   update)
     # pass through to server update script
     REMOTE_UPDATE_SCRIPT="sync/server/update.sh"
     shift
   ;;
   force-local-update)
     # pass through to server update script
     update-local --force
     exit
   ;;
   checkout)
     REMOTE_UPDATE_SCRIPT="sync/server/sync.sh"
     FORCE_ARG="--force"
     #pass through to server sync script
   ;;
   working-on)
     if [ "$2" = "--remote" ]; then
       echo "$(cat "$WORK_HEAD_FILE_REMOTE")"
     else
       echo "$(cat "$WORK_HEAD_FILE")"
     fi
     exit
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

if [ -z "$SSH_CONNECT" ]; then
  ( cd "$REMOTE_PATH" && "${GIT_DIR:-./.git}/$REMOTE_UPDATE_SCRIPT" "${@}" ) > >(record-working) || die "local remote command failed"
else
  # escape the arguments
  declare -a args
  count=0
  for arg in "$@"; do
    args[count]=$(printf '%q' "$arg")
    count=$((count+1))
  done
  ssh "$SSH_CONNECT" "cd "$REMOTE_PATH" && "\${GIT_DIR:-./.git}/$REMOTE_UPDATE_SCRIPT" "${args[@]}"" > >(record-working) || die "remote command failed"
fi

update-local "$FORCE_ARG"
