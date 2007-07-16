#!/bin/bash
#
# InstallFramework.sh
# buildtools
#
# Created by Wincent Colaiuta on 06/12/04.
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
TOOL="/usr/bin/install_name_tool"
EMBEDDED_PREFIX="@executable_path/../Frameworks"
INSTALLED_PREFIX="/Library/Frameworks"

#
# Functions
# 
printusage()
{
  builtin echo 'Usage: $0 new-ID [dependent-library ...]'
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
  ID=$1
fi

if [ "${FRAMEWORK_VERSION}" = "" ]; then
  builtin echo "FRAMEWORK_VERSION not set: using default value A"
  FRAMEWORK_VERSION="A"
fi

builtin echo "Removing old version of framework ${ID}.framework from ${INSTALLED_PREFIX}, if present"
/bin/rm -rf "${INSTALLED_PREFIX}/${ID}.framework"

builtin echo "Copying framework ${ID}.framework into ${INSTALLED_PREFIX}, overwriting old version if present"
/bin/cp -vfR "${TARGET_BUILD_DIR}/${ID}.framework" "${INSTALLED_PREFIX}/"
cd "${INSTALLED_PREFIX}/${ID}.framework/Versions/${FRAMEWORK_VERSION}"

NEW_ID="${INSTALLED_PREFIX}/${ID}.framework/Versions/${FRAMEWORK_VERSION}/${ID}"
builtin echo "Changing ID for ${ID}.framework to ${NEW_ID}"
"${TOOL}" -id "${NEW_ID}" "${ID}"

while shift
do
  DEPENDENT_LIBRARY=$1
  OLD_NAME="${EMBEDDED_PREFIX}/${DEPENDENT_LIBRARY}.framework/Versions/${FRAMEWORK_VERSION}/${DEPENDENT_LIBRARY}"
  NEW_NAME="${INSTALLED_PREFIX}/${DEPENDENT_LIBRARY}.framework/Versions/${FRAMEWORK_VERSION}/${DEPENDENT_LIBRARY}"
  builtin echo "Changing dependent shared library name for ${ID}.framework from:"
  builtin echo "  ${OLD_NAME}"
  builtin echo "To:"
  builtin echo "  ${NEW_NAME}"
  "${TOOL}" -change "${OLD_NAME}" "${NEW_NAME}" "${ID}" 
done

builtin echo "$0: Done"
exit 0
