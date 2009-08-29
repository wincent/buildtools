#!/bin/sh -e
# ReleaseNotes.sh
# buildtools
#
# Copyright 2007-2009 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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

# find out if we are at a tag or somewhere ahead of one
# BUG: git describe will bail here with 128 exit status if no annotated tags in repo
TAG=$(git describe)
ABBREV_TAG=$(git describe --abbrev=0)
if [ "$TAG" = "$ABBREV_TAG" ]; then
  # currently at a tag
  AHEAD=''
else
  # somewhere ahead of a tag
  AHEAD='true'
fi

if [ -n "$TAG_PREFIX" ]; then
  if [ -n "$AHEAD" ]; then
    PREV_TAG=$(git tag -l "$TAG_PREFIX*" | tail -n 1)
  else
    TAG=$(git tag -l "$TAG_PREFIX*" | tail -n 1)
    PREV_TAG=$(git tag -l "$TAG_PREFIX*" | tail -n 2 | head -1)
  fi
else
  # no explict tag prefix
  if [ -n "$AHEAD" ]; then
    PREV_TAG=$ABBREV_TAG
  else
    PREV_TAG=$(git describe HEAD^ --abbrev=0)
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

echo ""
echo ""
