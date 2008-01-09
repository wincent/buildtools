#!/bin/sh
#
# StripFrameworkSymbols.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
#
# Copyright 2004-2008 Wincent Colaiuta.
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
SYMBOLSFILE="${SOURCE_ROOT}/no-strip-symbols"

#
# Functions
#
printusage()
{
  builtin echo 'Usage: $0 [no-strip-symbols-file]'
  builtin echo 'If "no-strip-symbols-file" is omitted "${SOURCE_ROOT}/no-strip-symbols" is assumed'
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  SYMBOLSFILE="$1"
elif [ $# -gt 1 ]; then
  printusage
  exit 1
fi

if [ -z "${FRAMEWORK_VERSION}" ]; then
  builtin echo "FRAMEWORK_VERSION not set: using default value A"
  FRAMEWORK_VERSION="A"
fi

# issue error message if symbols file not found
if [ ! -f "${SYMBOLSFILE}" ]; then
  err "${SYMBOLSFILE} not found"
  exit 1
fi

if [ ${CONFIGURATION} == "Debug" ]; then
  builtin echo "Debug build: not stripping symbols"
elif [ ${CONFIGURATION} == "Release" ]; then
  FRAMEWORK="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Versions/${FRAMEWORK_VERSION}/${PRODUCT_NAME}"
  builtin echo "Release build: Stripping symbols from ${FRAMEWORK}"
  strip -u -r -s "${SYMBOLSFILE}" "${FRAMEWORK}"
else
  builtin echo "Unknown configuration"
  exit 1
fi

builtin echo "$0: Done"
exit 0