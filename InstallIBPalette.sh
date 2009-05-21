#!/bin/sh
# InstallIBPalette.sh
# buildtools
#
# Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

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
