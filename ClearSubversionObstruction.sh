#!/bin/bash
#
# ClearSubversionObstruction.sh
# buildtools
#
# Created by Wincent Colaiuta on Fri Dec 30 2003.
# 
# Copyright 2003-2006 Wincent Colaiuta.
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
