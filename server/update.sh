#!/usr/bin/env bash

die() {
  echo "$1" >&2
  exit 1
}

if [ $# -gt 1 ]; then
  die "too many arguments: \"${*}\""
fi

DEV_BRANCH="dev"
TMP_BRANCH="tmp"
WORK_BRANCH="work"
BACKUP_TAG="work_backup"
COMMIT_MESSAGE="$1"
git fetch --all || die "remote fetch failed"
if [ -z "$COMMIT_MESSAGE" ]; then
  if [ "$(git log --oneline "${DEV_BRANCH}..${WORK_BRANCH}" | wc -l)" -lt 2 ]; then
    die "up-to-date, nothing to do"
  fi
  COMMIT_MESSAGE="update auto-message"
fi
git tag -d "$BACKUP_TAG"
git tag "$BACKUP_TAG"
git branch "$TMP_BRANCH" "$DEV_BRANCH"
git rebase "$TMP_BRANCH" || die "remote rebase failed"
git checkout "$TMP_BRANCH"
git merge --squash "$WORK_BRANCH" || die "remote squash merge failed"
git commit -m "$COMMIT_MESSAGE"
git checkout "$WORK_BRANCH" || die "failed to checkout $WORK_BRANCH on remote"
MERGE_BASE=$(git merge-base "$WORK_BRANCH" "$TMP_BRANCH") || die "failed to get merge-base on remote"
git reset --hard "$MERGE_BASE" || die "remote hard reset failed (merge-base: $MERGE_BASE)"
git merge --ff-only "$TMP_BRANCH" || die "failed to merge $TMP_BRANCH into $WORK_BRANCH on remote"
if [ -n "$1" ]; then
  git checkout "$DEV_BRANCH" || die "remote failed to checkout $DEV_BRANCH"
  git merge --ff-only "$TMP_BRANCH" || die "failed to merge $TMP_BRANCH into $DEV_BRANCH on remote"
  git checkout "$WORK_BRANCH" || die "failed to checkout $WORK_BRANCH on remote"
fi
git branch -d "$TMP_BRANCH" || die "failed to delete $TMP_BRANCH"
