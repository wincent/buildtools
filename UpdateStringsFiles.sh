#!/bin/sh
#
# UpdateStringsFiles.sh
# buildtools
#
# Created by Wincent Colaiuta on 30 December 2003.
# 
# Copyright 2003-2008 Wincent Colaiuta.
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

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Defaults
#

DEVLANGUAGE="en"

#
# Functions
#

printusage()
{
  echo "Usage:    $0 src_path resources_path"
  echo "Example:  $0 ~/project/src ~/project/resources"
  echo "Note:     By design this script is not recursive"
}

#
# Main
#

set -e

# process arguments
if [ $# -ne 2 ]; then
  printusage
  exit 1
fi
SRC_DIR=$1
RESOURCE_DIR=$2

# Xcode bug: "English" passed as DEVELOPMENT_LANGUAGE even when it should be "en"
test -d "$RESOURCE_DIR/${DEVLANGUAGE}.lproj" ||
  die "${DEVLANGUAGE}.lproj folder not found in $RESOURCE_DIR"

# write output files to a temporary directory first so we can compare them for changes
TMPDIR=$(mktemp -d /private/tmp/com.wincent.buildtools.UpdateStringsFiles.XXXXXX) ||
  die "couldn't create temporary directory"

# make backups of existing strings files
echo "Making backups of old strings files in $RESOURCE_DIR/${DEVLANGUAGE}.lproj"
find "$RESOURCE_DIR/${DEVLANGUAGE}.lproj" -name '*.strings' -print -exec \
  cp -vf "{}" "{}.bak" \;

# update development language localizable strings file(s)
echo "Will close these files if they are open:"
for STRINGSFILE in $(find "$RESOURCE_DIR/${DEVLANGUAGE}.lproj" -name '*.strings' -print); do
  close "${STRINGSFILE}"
done

echo "Running genstrings"
genstrings -u -o "$RESOURCE_DIR/$DEVLANGUAGE.lproj" "$SRC_DIR"/*.m "$SRC_DIR"/*.c "$SRC_DIR"/*.h

for LANGUAGE in $(find "$RESOURCE_DIR" -name '*.lproj' -depth 1 -not -name "${DEVLANGUAGE}.lproj"); do
  builtin echo "Making backups of old strings files in $LANGUAGE"
  find "$LANGUAGE" -name '*.strings' -print -exec \
    cp -vf "{}" "{}.bak" \;

  for STRINGSFILE in $(ls "$RESOURCE_DIR/${DEVLANGUAGE}.lproj" | grep '\.strings$'); do
    # shield Xcode from the trauma of open files being edited
    close "$STRINGSFILE"

    # wincent-strings-util will bail for non-existent merge files
    builtin echo "Touching $LANGUAGE/$STRINGSFILE"
    touch "$LANGUAGE/$STRINGSFILE"

    mkdir -p $(dirname "$TMPDIR/$LANGUAGE/$STRINGSFILE")
    wincent-strings-util --base "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" \
      --merge   "${LANGUAGE}/${STRINGSFILE}" \
      --output  "$TMPDIR/$LANGUAGE/$STRINGSFILE" 2> /dev/null
    if compare "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" "$TMPDIR/$LANGUAGE/$STRINGSFILE"; then
      builtin echo "Merging $LANGUAGE/$STRINGSFILE"
      wincent-strings-util --base "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" \
        --merge   "${LANGUAGE}/${STRINGSFILE}" \
        --output  "${LANGUAGE}/${STRINGSFILE}"
    fi
   done
done

exit 0

