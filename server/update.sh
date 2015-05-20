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
echo 1
git fetch --all
echo 2
git tag -d "$BACKUP_TAG"
echo 3
git tag "$BACKUP_TAG"
echo 4
git branch "$TMP_BRANCH" "$DEV_BRANCH"
echo 5
git rebase "$TMP_BRANCH"
echo 6
git checkout "$TMP_BRANCH"
echo 7
git merge --squash "$WORK_BRANCH"
echo 8
git commit -m "$COMMIT_MESSAGE"
echo 9
git checkout "$WORK_BRANCH"
echo 10
git reset --hard $(git merge-base "$WORK_BRANCH" "$TMP_BRANCH")
echo 11
git merge --ff-only "$TMP_BRANCH"
if [ -z "$1" ]; then
echo 12
  git checkout "$DEV_BRANCH"
echo 13
  git merge --ff-only "$TMP_BRANCH"
echo 14
  git checkout "$WORK_BRANCH"
fi
echo 15
git branch -d "$TMP_BRANCH"
