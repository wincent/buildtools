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
# Main
#

set -e

# expect one argument: the resource folder in which we are to operate
test $# = 1 || die "expected 1 argument but received $#"
cd $1

BASE="en.lproj"
test -d "$BASE" || die "base directory $BASE not found in $1"

for LOC in $(find . -type d -name '*.lproj' -not -name "$BASE"); do
  for BASE_XIB in $(find "$BASE" -name '*.xib'); do
    XIB=$(basename "$BASE_XIB")
    TARGET_XIB="$LOC/$XIB"
    if [ ! -f "$TARGET_XIB" ]; then
      note "Target xib '$TARGET_XIB' does not exist; cloning from $BASE_XIB"
      cp "$BASE_XIB" "$TARGET_XIB"
    fi

    TARGET_STRINGS=$(echo "$TARGET_XIB" | sed -e 's/.xib/.strings/')
    if [ ! -f "$TARGET_STRINGS" ]; then
      echo "Target strings file '$TARGET_STRINGS' does not exist; generating."
      ibtool --generate-stringsfile "$TARGET_STRINGS" "$TARGET_XIB"
    fi
  done
done

