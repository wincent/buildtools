#!/bin/sh
#
# RunDoxygen.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
#
# Copyright 2004-2007 Wincent Colaiuta.
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
DOXYFILE="${SOURCE_ROOT}/Doxyfile"
#DOXYGEN="doxygen"
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
  err "${DOXYGEN} not found"
  exit 1
fi

cd "${SOURCE_ROOT}"
builtin echo "Running Doxygen:"
"${DOXYGEN}" "${DOXYFILE}"
builtin echo "$0: Done"
cd -

exit 0