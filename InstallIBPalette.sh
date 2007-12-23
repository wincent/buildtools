#!/bin/sh
#
# InstallIBPalette.sh
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

#
# Defaults
#
TOOL="install_name_tool"
EMBEDDED_PREFIX="@executable_path/../Frameworks"
INSTALLED_PREFIX="/Library/Frameworks"
DEST_DIR="${HOME}/Library/Palettes"

#
# Functions
# 
printusage()
{
  builtin echo 'Usage: $0 base-name [dependent-library ...]'
}
 
#
# Main
#

set -e

# process arguments
if [ $# -lt 1 ]; then
  printusage
  exit 1
else
  BASE_NAME=$1
fi

if [ -z "${FRAMEWORK_VERSION}" ]; then
  builtin echo "FRAMEWORK_VERSION not set: using default value A"
  FRAMEWORK_VERSION="A"
fi

builtin echo "Removing old version of palette ${BASE_NAME}.palette from ${DEST_DIR}, if present"
rm -rf "${DEST_DIR}/${BASE_NAME}.palette"

builtin echo "Copying palette ${BASE_NAME}.palette into ${DEST_DIR}, overwriting old version if present"
cp -vfR "${TARGET_BUILD_DIR}/${BASE_NAME}.palette" "${DEST_DIR}/"
cd "${DEST_DIR}/${BASE_NAME}.palette/Contents/MacOS"

while shift
do
  DEPENDENT_LIBRARY=$1
  OLD_NAME="${EMBEDDED_PREFIX}/${DEPENDENT_LIBRARY}.framework/Versions/${FRAMEWORK_VERSION}/${DEPENDENT_LIBRARY}"
  NEW_NAME="${INSTALLED_PREFIX}/${DEPENDENT_LIBRARY}.framework/Versions/${FRAMEWORK_VERSION}/${DEPENDENT_LIBRARY}"
  builtin echo "Changing dependent shared library name for ${BASE_NAME}.palette from:"
  builtin echo "  ${OLD_NAME}"
  builtin echo "To:"
  builtin echo "  ${NEW_NAME}"
  "${TOOL}" -change "${OLD_NAME}" "${NEW_NAME}" "${BASE_NAME}" 
done

builtin echo "$0: Done"
exit 0
