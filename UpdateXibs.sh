#!/bin/sh -e
#
# UpdateXibs.sh
# buildtools
#
# Created by Wincent Colaiuta on 20 December 2007.
#
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

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Functions
#

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

# returns 0 (success) if the two input files differ, 1 otherwise
compare()
{
  ! diff "$1" "$2" > /dev/null 2>&1
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

# create/update strings files in base language if required
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
  fi
done

for LOC in $(find . -type d -name '*.lproj' -depth 1 -not -name "$BASE"); do
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
    fi

    # merge new strings from base langauge into target language strings files
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

