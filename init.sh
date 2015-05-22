#!/usr/bin/env bash

SYNC_DIR=$( cd $(dirname $0) && pwd -L )

WORK_BRANCH="work"

die() {
  echo "$1" >&2
  exit 1
}

create-work-branch() {
    if ! git rev-parse "refs/heads/$WORK_BRANCH" >/dev/null 2>&1; then
      git --work-tree="../" checkout -b "$WORK_BRANCH" || die "failed checkout -b ($PWD)"
    else
      git --work-tree="../" checkout "$WORK_BRANCH" || die "failed checkout ($PWD)"
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
    create-work-branch
  ;;
  client)
    echo "configure for client"
    git config alias.sync "!${GIT_DIR:-./.git}/sync/client/sync.sh"
    create-work-branch
  ;;
  *)
    echo "unrecognized option: $1" >&2
  ;;
esac

)
