#!/bin/bash
#
# StripFrameworkSymbols.sh
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

if [ "${FRAMEWORK_VERSION}" = "" ]; then
  builtin echo "FRAMEWORK_VERSION not set: using default value A"
  FRAMEWORK_VERSION="A"
fi

# issue error message if symbols file not found
if [ ! -f "${SYMBOLSFILE}" ]; then
  builtin echo "error: ${SYMBOLSFILE} not found"
  exit 1
fi

if [ ${CONFIGURATION} == "Debug" ]; then
  builtin echo "Debug build: not stripping symbols"
elif [ ${CONFIGURATION} == "Release" ]; then
  FRAMEWORK="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Versions/${FRAMEWORK_VERSION}/${PRODUCT_NAME}"
  builtin echo "Release build: Stripping symbols from ${FRAMEWORK}"
  /usr/bin/strip -u -r -s "${SYMBOLSFILE}" "${FRAMEWORK}"
else
  builtin echo "Unknown configuration"
  exit 1
fi

builtin echo "$0: Done"
exit 0