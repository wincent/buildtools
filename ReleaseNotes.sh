#!/bin/sh -e
#
# release-notes.sh
# Emit code-level release notes since the last tag.
#
# Created by Wincent Colaiuta on 27 November 2007.
# Copyright 2007 Wincent Colaiuta.

# bail early if not inside a Git repo
git rev-parse --is-inside-work-tree 1> /dev/null 2>&1 || exit

TAG=$(git describe)
ABBREV_TAG=$(git describe --abbrev=0)
if [ "$TAG" = "$ABBREV_TAG" ]; then
  # currently at a tag
  PREV_TAG=$(git-describe HEAD^ --abbrev=0)
else
  # somewhere ahead of a tag
  PREV_TAG=$ABBREV_TAG
fi

echo "Changes from $PREV_TAG to $TAG:\n"
git log $TAG ^$PREV_TAG | git shortlog

