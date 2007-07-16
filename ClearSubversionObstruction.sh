#!/bin/bash
#
# ClearSubversionObstruction.sh
# buildtools
#
# Created by Wincent Colaiuta on Fri Dec 30 2003.
# 
# Copyright 2003-2006 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#

# Handle case where "svn status" reports that a bundle has status "~" ("versioned item obstructed by some item of a different kind")

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 bundle-directory"
}

#
# Main
#

set -e

# process arguments
if [ $# -ne 1 ]; then
  printusage
  exit 1
fi
if [ ! -d "$1" ]; then
  printusage
  exit 1
fi
BUNDLE="$1"

/bin/mv -v "${BUNDLE}" "${BUNDLE}.svnhack"
/usr/local/bin/svn update "${BUNDLE}"
/bin/mv -v "${BUNDLE}/.svn" "${BUNDLE}.svnhack/"
/bin/rm -rv "${BUNDLE}"
/bin/mv -v "${BUNDLE}.svnhack" "${BUNDLE}"

builtin echo "svn status of ${BUNDLE}:"
/usr/local/bin/svn status "${BUNDLE}"
builtin echo "ClearSubversionObstruction.sh: Done"

exit 0
