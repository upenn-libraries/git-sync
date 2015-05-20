#!/usr/bin/env bash

if [ $# -gt 1 ]; then
  echo "too many arguments: \"${*}\"" >&2
  exit 1
fi

DEV_BRANCH="dev"
TMP_BRANCH="tmp"
WORK_BRANCH="work"
BACKUP_TAG="work_backup"
COMMIT_MESSAGE="$1"
if [ -z "$COMMIT_MESSAGE" ]; then
  COMMIT_MESSAGE="update auto-message"
fi
git fetch --all
git tag -d "$BACKUP_TAG"
git tag "$BACKUP_TAG"
git branch "$TMP_BRANCH" "$DEV_BRANCH"
git rebase "$TMP_BRANCH"
git checkout "$TMP_BRANCH"
git merge --squash "$WORK_BRANCH"
git commit -m "$COMMIT_MESSAGE"
git checkout "$WORK_BRANCH"
git reset --hard $(git merge-base "$WORK_BRANCH" "$TMP_BRANCH")
git merge --ff-only "$TMP_BRANCH"
if [ -n "$1" ]; then
  git checkout "$DEV_BRANCH"
  git merge --ff-only "$TMP_BRANCH"
  git checkout "$WORK_BRANCH"
fi
git branch -d "$TMP_BRANCH"
