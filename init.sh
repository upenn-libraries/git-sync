#!/usr/bin/env bash

SYNC_DIR=$( cd $(dirname $0) && pwd -L )

WORK_BRANCH="work"
WORK_HEAD_FILE="$SYNC_DIR/WORK_HEAD"


die() {
  echo "$1" >&2
  exit 1
}

create-work-branch() {
  if git rev-parse "refs/heads/$WORK_BRANCH" >/dev/null 2>&1 || [ "$1" != "server" ]; then
    git --work-tree="../" checkout "$WORK_BRANCH" || die "failed checkout ($PWD)"
  else
    git --work-tree="../" checkout -b "$WORK_BRANCH" || die "failed checkout -b ($PWD)"
  fi
}

(

cd "$SYNC_DIR/../"

case "$1" in
  server)
    echo "configure for server"
    git config receive.denyCurrentBranch ignore
    git config alias.sync "!${GIT_DIR:-./.git}/sync/server/sync.sh"
    ln -s ../sync/server/hooks/post-update hooks/post-update
    branch_name="$(git symbolic-ref HEAD 2>/dev/null)" || die "no branch found; checkout a branch and re-init"
    create-work-branch server
    echo "$branch_name" > "$WORK_HEAD_FILE"
  ;;
  client)
    echo "configure for client"
    git config alias.sync "!${GIT_DIR:-./.git}/sync/client/sync.sh"
    create-work-branch
    git --work-tree="../" sync update
    export GIT_WORK_TREE="$PWD/../"
    git sync force-local-update
  ;;
  *)
    echo "unrecognized option: $1" >&2
  ;;
esac

)
