#!/bin/bash
#
# UpdateStringsFile.sh
# buildtools
#
# Created by Wincent Colaiuta on 2 April 2007.
# 
# Copyright 2007 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#

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
  builtin echo "Usage:   $0 source-file-name [development-language]"
  builtin echo "Pass absolute paths"
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
BASEFILE="$1"
BASEDIR=$(dirname "${BASEFILE}")

# check for primary development language (normally "en")
cd "${BASEDIR}"
if [ ! -e "${DEVLANGUAGE}.lproj" ]
then
  builtin echo ":: error: ${DEVLANGUAGE}.lproj folder not found in ${BASEDIR}"
  exit 1
fi

# make backups of existing strings files
builtin echo "Making backups of old strings files in ${DEVLANGUAGE}.lproj"
/usr/bin/find "${DEVLANGUAGE}.lproj" -name "*.strings" -print -exec \
  /bin/cp -vf "{}" "{}.bak" \;

# update development language localizable strings file(s)
builtin echo "Will close these files if they are open:"
for STRINGSFILE in `/usr/bin/find "${DEVLANGUAGE}.lproj" -name "*.strings" -print`
do
  close "${STRINGSFILE}"
done

builtin echo "Running genstrings"
/usr/bin/genstrings -u -o "${DEVLANGUAGE}.lproj" "${BASEFILE}"

for LANGUAGE in `/usr/bin/find . -name "*.lproj" -maxdepth 1`
do
  builtin echo "Processing localization in folder: ${LANGUAGE}"
  if [ "${LANGUAGE}" = "./${DEVLANGUAGE}.lproj" ]; then
    builtin echo "Skipping (${DEVLANGUAGE} is the development language)"
    continue
  fi
  
  builtin echo "Making backups of old strings files in ${LANGUAGE}"
  /usr/bin/find "${LANGUAGE}" -name "*.strings" -print -exec \
    /bin/cp -vf "{}" "{}.bak" \;
  
  for STRINGSFILE in `/bin/ls "${DEVLANGUAGE}.lproj" | \
                      /usr/bin/grep "\.strings$"`
  do
    # shield Xcode from the trauma of open files being edited
    close "${STRINGSFILE}"
    
    # wincent-strings-util will bail for non-existent merge files
    builtin echo "Touching ${LANGUAGE}/${STRINGSFILE}"
    /usr/bin/touch "${LANGUAGE}/${STRINGSFILE}"
    
    builtin echo "Merging ${LANGUAGE}/${STRINGSFILE}"
    ${GLOT} -base "${DEVLANGUAGE}.lproj/${STRINGSFILE}"  \
            -merge "${LANGUAGE}/${STRINGSFILE}"          \
            -output "${LANGUAGE}/${STRINGSFILE}"
   
   done

done

builtin echo "$0: Done"
exit 0

