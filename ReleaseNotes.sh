#!/bin/sh -e
#
# ReleaseNotes.sh
# buildtools
#
# Emit code-level release notes since the last tag.
#
# Created by Wincent Colaiuta on 27 November 2007.
# Copyright 2007 Wincent Colaiuta.
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

