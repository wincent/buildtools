#!/bin/sh -e
# git-last-tag.sh
# buildtools
#
# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
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

if [ -z "$BUILDTOOLS_DIR" ]; then
  # set up BUILDTOOLS_DIR, allowing for convenient use outside of Xcode
  BUILDTOOLS_DIR=$(cd $(dirname "$0") && pwd)
fi

. "$BUILDTOOLS_DIR/Common.sh"

# bail early if not inside a Git repo
git rev-parse --is-inside-work-tree 1> /dev/null 2>&1 || die 'not inside a Git repository'

# find out if we are at a tag or somewhere ahead of one
TAG=$(git describe) || die 'no annotated tags in repo'
ABBREV_TAG=$(git describe --abbrev=0)
if [ "$TAG" = "$ABBREV_TAG" ]; then
  # currently at a tag
  PREV_TAG=$(git describe HEAD^ --abbrev=0 2> /dev/null || true)
  if [ -z "$PREV_TAG" ]; then
    # no previous tags; use (first) root commit
    PREV_TAG=$(git rev-list HEAD | tail -n 1)
  fi
else
  # somewhere ahead of a tag
  PREV_TAG=$ABBREV_TAG
fi

echo $PREV_TAG
