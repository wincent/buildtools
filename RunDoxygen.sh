#!/bin/bash
#
# RunDoxygen.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
#
# Copyright 2004-2006 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#

#
# Defaults
#
DOXYFILE="${SOURCE_ROOT}/Doxyfile"
#DOXYGEN="/usr/local/bin/doxygen"
DOXYGEN="/Applications/Doxygen.app/Contents/Resources/doxygen"

#
# Functions
#
printusage()
{
  builtin echo 'Usage: $0 [Doxyfile]'
  builtin echo 'If "Doxyfile" is omitted "${SOURCE_ROOT}/Doxyfile" is assumed' 
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  DOXYFILE="$1"
elif [ $# -gt 1 ]; then
  printusage
  exit 1
fi

# issue error message if Doxygen not installed
if [ ! -f "${DOXYGEN}" ]; then
  builtin echo "error: ${DOXYGEN} not found"
  exit 1
fi

cd "${SOURCE_ROOT}"
builtin echo "Running Doxygen:"
"${DOXYGEN}" "${DOXYFILE}"
builtin echo "RunDoxygen.sh: Done"
cd -

exit 0