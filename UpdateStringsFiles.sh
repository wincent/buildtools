#!/bin/sh
# UpdateStringsFiles.sh
# buildtools
#
# Copyright 2003-present Greg Hurrell. All rights reserved.
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

  # LANGUAGE is an absolute path, so get base part as well
  BASE_LANGUAGE=$(basename "$LANGUAGE")

  for STRINGSFILE in $(ls "$RESOURCE_DIR/${DEVLANGUAGE}.lproj" | grep '\.strings$'); do
    # shield Xcode from the trauma of open files being edited
    close "$STRINGSFILE"

    # wincent-strings-util will bail for non-existent merge files
    builtin echo "Touching $LANGUAGE/$STRINGSFILE"
    touch "$LANGUAGE/$STRINGSFILE"

    mkdir -p $(dirname "$TMPDIR/$BASE_LANGUAGE/$STRINGSFILE")
    wincent-strings-util --base "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" \
      --merge   "${LANGUAGE}/${STRINGSFILE}" \
      --output  "$TMPDIR/$BASE_LANGUAGE/$STRINGSFILE" 2> /dev/null
    if compare "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" "$TMPDIR/$BASE_LANGUAGE/$STRINGSFILE"; then
      builtin echo "Merging $LANGUAGE/$STRINGSFILE"
      wincent-strings-util --base "$RESOURCE_DIR/${DEVLANGUAGE}.lproj/$STRINGSFILE" \
        --merge   "${LANGUAGE}/${STRINGSFILE}" \
        --output  "${LANGUAGE}/${STRINGSFILE}"
    fi
   done
done

exit 0
