#!/bin/sh -e
#
# ReleaseNotes.sh
# buildtools
#
# Emit code-level release notes since the last tag.
#
# Created by Wincent Colaiuta on 27 November 2007.
# Copyright 2007-2008 Wincent Colaiuta.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Xcode will ignore the shebang line, making the -e above ineffective
set -e

. "$BUILDTOOLS_DIR/Common.sh"

#
# Functions
#

usage()
{
  echo 'Usage: ReleaseNotes.sh [--long] [--tag-prefix=prefix]'
  exit 1
}

# bail early if not inside a Git repo
git rev-parse --is-inside-work-tree 1> /dev/null 2>&1 || die 'not inside a Git repository'

# process arguments
LONG=
TAG_PREFIX=
while test $# != 0
do
  case "$1" in
  --long)
    LONG=true
    ;;
  --tag-prefix=*)
    TAG_PREFIX="${1#--tag-prefix=}"
    ;;
  *)
    usage
    ;;
  esac
  shift
done

if [ -n "$TAG_PREFIX" ]; then
  TAG=$(git tag -l "$TAG_PREFIX*" | tail -n 1)
  PREV_TAG=$(git tag -l "$TAG_PREFIX*" | tail -n 2 | head -1)
else
  # no explict tag prefix
  TAG=$(git describe)
  ABBREV_TAG=$(git describe --abbrev=0)
  if [ "$TAG" = "$ABBREV_TAG" ]; then
    # currently at a tag
    PREV_TAG=$(git describe HEAD^ --abbrev=0)
  else
    # somewhere ahead of a tag
    PREV_TAG=$ABBREV_TAG
  fi
fi

test -n "$TAG" || die 'no value for TAG'
test -n "$PREV_TAG" || die 'no value for PREV_TAG'

# if we use: builtin echo -e "...\n"    works only from within Xcode and not interactively
# if we use: echo "...\n"               works interactively but not from within Xcode
# so fake it (kludge):
echo "Changes from $PREV_TAG to $TAG:"
echo ""

if [ -n "$LONG" ]; then
  git log $PREV_TAG..$TAG
else
  git log --pretty=format:'    %s' $PREV_TAG..$TAG
fi
