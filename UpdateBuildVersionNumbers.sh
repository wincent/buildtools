#!/bin/sh
#
# UpdateBuildVersionNumbers.sh
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

# The following macro definition is updated, if present:
#
#    /* START: Auto-updated macro definitions */
#
#    #define WO_COPYRIGHT_YEAR  2003-2004
#
#    /* END: Auto-updated macro definitons */
#
# The file containing the versioning information should not be updated by hand
# because its content is "brittle" and changing it may prevent this script from
# updating the information.

# NOTE: If info plist preprocessing is turned on in Xcode, it happens *before* any shell scripts get run.
# Must therefore call this script from a separate target *before* building the main target.

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 version-file"
}

update_copyright_years()
{
  builtin echo "Updating WO_COPYRIGHT_YEAR entry"
  
  # get current year
  YEAR=$(date +%Y)
  
  # in the line : #define WO_COPYRIGHT_YEAR ... update: "... XXXX ..."
  cat "${SOURCE_ROOT}/${WO_VERSION_FILE}" | sed \
    -e "/^#define[ ][ ]*WO_COPYRIGHT_YEAR[ ]/s/\(.*\)[0-9]\{4\}\([^\-]*\)/\1${YEAR}\2/" \
    > "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp"
  
  if [ $? -eq 0 ]; then
    
    # only copy the file if it's actually different
    if compare "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp" "${SOURCE_ROOT}/${WO_VERSION_FILE}"; then
      cp -fv "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp" \
             "${SOURCE_ROOT}/${WO_VERSION_FILE}"
    fi
    
  else
    err "non-zero exit status during copyright update"
    exit 1
  fi
}

#
# Main
# 

set -e

# process arguments
if [ $# -eq 1 ]; then
  WO_VERSION_FILE="$1"
else
  printusage
  exit 1
fi

# Backup old version of file
close "${WO_VERSION_FILE}"
builtin echo "Making backup of ${WO_VERSION_FILE}"

cp -fv "${SOURCE_ROOT}/${WO_VERSION_FILE}" \
       "${SOURCE_ROOT}/${WO_VERSION_FILE}.bak"

# Scan for copyright and update
update_copyright_years

# ensure all pending writes flushed to disk
sync

builtin echo "$0: Done"
