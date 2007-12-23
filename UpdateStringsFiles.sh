#!/bin/sh
#
# UpdateStringsFiles.sh
# buildtools
#
# Created by Wincent Colaiuta on Fri Dec 30 2003.
# 
# Copyright 2003-2007 Wincent Colaiuta.
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

GLOT="wincent-strings-util"
DEVLANGUAGE="en"

#
# Functions
#

printusage()
{
  # BUG: Xcode always passes "English" as DEVELOPMENT_LANGUAGE environment variable, even when it should pass "en"
  # as a result, must explicitly specify dev language as an argument to this script
  builtin echo "Usage:   $0 unlocalized-resources-folder [development-language]"
  builtin echo "Where:   \"unlocalized-resources-folder\" contains your source and .lproj folders"
  builtin echo "         \"development-language\", if not specified, defaults to \"en\""
  builtin echo "Example: $0 ~/Project/src"
  builtin echo "Note:    By design this script is not recursive"
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 2 ]; then
  DEVLANGUAGE="$2"
elif [ $# -gt 2 -o $# -lt 1 ]; then
  printusage
  exit 1
fi
BASEDIR="$1"

# check for primary development language (normally "en")
cd "${BASEDIR}"
if [ ! -e "${DEVLANGUAGE}.lproj" ]
then
  err "${DEVLANGUAGE}.lproj folder not found in ${BASEDIR}"
  exit 1
fi

# make backups of existing strings files
builtin echo "Making backups of old strings files in ${DEVLANGUAGE}.lproj"
find "${DEVLANGUAGE}.lproj" -name "*.strings" -print -exec \
  cp -vf "{}" "{}.bak" \;

# update development language localizable strings file(s)
builtin echo "Will close these files if they are open:"
for STRINGSFILE in $(find "${DEVLANGUAGE}.lproj" -name "*.strings" -print)
do
  close "${STRINGSFILE}"
done

builtin echo "Running genstrings"
genstrings -u -o "${DEVLANGUAGE}.lproj" *.m *.c *.h

for LANGUAGE in $(find . -name "*.lproj" -maxdepth 1)
do
  builtin echo "Processing localization in folder: ${LANGUAGE}"
  if [ "${LANGUAGE}" = "./${DEVLANGUAGE}.lproj" ]; then
    builtin echo "Skipping (${DEVLANGUAGE} is the development language)"
    continue
  fi
  
  builtin echo "Making backups of old strings files in ${LANGUAGE}"
  find "${LANGUAGE}" -name "*.strings" -print -exec \
    cp -vf "{}" "{}.bak" \;
  
  for STRINGSFILE in `ls "${DEVLANGUAGE}.lproj" | \
                      grep "\.strings$"`
  do
    # shield Xcode from the trauma of open files being edited
    close "${STRINGSFILE}"
    
    # wincent-strings-util will bail for non-existent merge files
    builtin echo "Touching ${LANGUAGE}/${STRINGSFILE}"
    touch "${LANGUAGE}/${STRINGSFILE}"
    
    builtin echo "Merging ${LANGUAGE}/${STRINGSFILE}"
    ${GLOT} --base    "${DEVLANGUAGE}.lproj/${STRINGSFILE}" \
            --merge   "${LANGUAGE}/${STRINGSFILE}"          \
            --output  "${LANGUAGE}/${STRINGSFILE}"
   
   done

done

exit 0

