#!/bin/sh -e
# UpdateXibs.sh
# buildtools
#
# Copyright 2007-present Greg Hurrell. All rights reserved.
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
# Functions
#

processing()
{
  echo "$BOLD[Processing]$RESET $1"
}

checking()
{
  echo "$BOLD[Checking]$RESET $1"
}

generating()
{
  echo "$BOLD[Generating]$RESET $1"
}

merging()
{
  echo "$BOLD[Merging]$RESET $1"
}

extracting()
{
  echo "$BOLD[Extracting]$RESET $1"
}

updating()
{
  echo "$BOLD[Updating]$RESET $1"
}

cloning()
{
  echo "$BOLD[Cloning]$RESET $1"
}

skipping()
{
  echo "$BOLD[Skipping]$RESET $1"
}

combining()
{
  echo "$BOLD[Combining]$RESET $1"
}

#
# Main
#

set -e

# expect one argument: the resource folder in which we are to operate
test $# = 1 || die "expected 1 argument but received $#"
cd $1

BASE="en.lproj"
test -d "$BASE" || die "base directory $BASE not found in $1"

# write output files to a temporary directory first so we can compare them for changes
TMPDIR=$(mktemp -d /private/tmp/com.wincent.buildtools.UpdateXibs.XXXXXX) ||
  die "couldn't create temporary directory"

# without this an early exit might escape our notice
trap 'die "aborting due to non-zero exit status; try running again using sh -x to identify the command which failed"' EXIT

# create/update strings files in base language if required
processing "$BASE."
for BASE_XIB in $(find "$BASE" -name '*.xib'); do
  BASE_STRINGS=$(echo "$BASE_XIB" | sed -e 's/\.xib/.strings/')
  if [ ! -f "$BASE_STRINGS" ]; then
    generating "Base strings file '$BASE_STRINGS'."
    ibtool --generate-stringsfile "$BASE_STRINGS" "$BASE_XIB"
  elif [ "$BASE_XIB" -nt "$BASE_STRINGS" ]; then
    mkdir -p $(dirname "$TMPDIR/$BASE_STRINGS")
    ibtool --generate-stringsfile "$TMPDIR/$BASE_STRINGS" "$BASE_XIB"
    if compare "$BASE_STRINGS" "$TMPDIR/$BASE_STRINGS"; then
      updating "Base strings file '$BASE_STRINGS'."
      cp "$TMPDIR/$BASE_STRINGS" "$BASE_STRINGS"
    else
      skipping "Base strings file '$BASE_STRINGS' (already up-to-date)."
    fi
  else
    skipping "Base strings file '$BASE_STRINGS' (newer than xib)."
  fi
done

# now iterate over target languages
for LOC in $(find . -type d -name '*.lproj' -depth 1 -not -name "$BASE"); do
  processing "$(basename $LOC)."
  for BASE_XIB in $(find "$BASE" -name '*.xib'); do

    # create xibs in target language if required
    XIB=$(basename "$BASE_XIB")
    TARGET_XIB="$LOC/$XIB"
    if [ ! -f "$TARGET_XIB" ]; then
      cloning "Target xib '$TARGET_XIB' from '$BASE_XIB'."
      note "'$TARGET_XIB' created (must add to Xcode project)."
      cp "$BASE_XIB" "$TARGET_XIB"
    fi

    # create/update strings files in target language if required
    TARGET_STRINGS=$(echo "$TARGET_XIB" | sed -e 's/\.xib/.strings/')
    if [ ! -f "$TARGET_STRINGS" ]; then
      generating "Target strings file '$TARGET_STRINGS'."
      ibtool --generate-stringsfile "$TARGET_STRINGS" "$TARGET_XIB"
    elif [ "$TARGET_XIB" -nt "$TARGET_STRINGS" ]; then
      mkdir -p $(dirname "$TMPDIR/$TARGET_STRINGS")
      ibtool --generate-stringsfile "$TMPDIR/$TARGET_STRINGS" "$TARGET_XIB"
      if compare "$TARGET_STRINGS" "$TMPDIR/$TARGET_STRINGS"; then
        updating "Target strings file '$TARGET_STRINGS'."
        cp "$TMPDIR/$TARGET_STRINGS" "$TARGET_STRINGS"
      else
        skipping "Target strings file '$TARGET_STRINGS' (already up-to-date)."
      fi
    else
      skipping "Target strings file '$TARGET_STRINGS' (newer than xib)."
    fi

    # merge new strings from base language into target language strings files
    BASE_STRINGS=$(echo "$BASE_XIB" | sed -e 's/\.xib/.strings/')
    mkdir -p $(dirname "$TMPDIR/$TARGET_STRINGS")
    wincent-strings-util --base "$BASE_STRINGS" \
      --merge "$TARGET_STRINGS" \
      --output "$TMPDIR/$TARGET_STRINGS" 2> /dev/null
    if compare "$TARGET_STRINGS" "$TMPDIR/$TARGET_STRINGS"; then
      updating "Target language strings file '$TARGET_STRINGS' (merging from base)."
      wincent-strings-util --base "$BASE_STRINGS" \
        --merge "$TARGET_STRINGS" \
        --output "$TARGET_STRINGS"
    else
      skipping "Target language strings file '$TARGET_STRINGS' (already up-to-date)."
    fi

    # produce/update incremental strings file
    INCREMENTAL=$(echo "$TARGET_STRINGS" | sed -e 's/\.strings/.untranslated.strings/')
    if [ ! -f "$INCREMENTAL" ]; then
      generating "Incremental strings file '$INCREMENTAL'."
      wincent-strings-util --base "$BASE_STRINGS" \
        --extract "$TARGET_STRINGS" \
        --output "$INCREMENTAL"
    elif [ "$TARGET_STRINGS" -nt "$INCREMENTAL" ]; then
      mkdir -p $(dirname "$TMPDIR/$INCREMENTAL")
      wincent-strings-util --base "$BASE_STRINGS" \
        --extract "$TARGET_STRINGS" \
        --output "$TMPDIR/$INCREMENTAL" 2> /dev/null
      if compare "$TARGET_STRINGS" "$TMPDIR/$INCREMENTAL"; then
        updating "Incremental strings file '$INCREMENTAL'."
        wincent-strings-util --base "$BASE_STRINGS" \
          --extract "$TARGET_STRINGS" \
          --output "$INCREMENTAL"
      else
        skipping "Incremental strings file '$INCREMENTAL' (already up-to-date)."
      fi
    fi

    # combine incremental strings files with existing files
    wincent-strings-util --base "$TARGET_STRINGS" \
      --combine "$INCREMENTAL" \
      --output "$TMPDIR/$TARGET_STRINGS" 2> /dev/null
    if compare "$TARGET_STRINGS" "$TMPDIR/$TARGET_STRINGS"; then
      combining "'$INCREMENTAL' and '$TARGET_STRINGS'."
      wincent-strings-util --base "$TARGET_STRINGS" \
        --combine "$INCREMENTAL" \
        --output "$TARGET_STRINGS"
    else
      skipping "Combination of '$INCREMENTAL' and '$TARGET_STRINGS' (already up-to-date)."
    fi

    # if old nib files exist try integrating latest strings

  done
done

trap '' EXIT
