#!/bin/bash
#
# Strip.sh
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
# Main
#

set -e

if [ "${DEPLOYMENT_POSTPROCESSING}" = "YES" ]; then
  builtin echo "Deployment postprocessing set to YES: stripping symbols"
else
  builtin echo "Deployment postprocessing not set YES: not stripping symbols"
  exit 0
fi

if [ "${WRAPPER_EXTENSION}" = "app" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Contents/MacOS/${EXECUTABLE_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "bundle" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Contents/MacOS/${EXECUTABLE_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "framework" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Versions/${FRAMEWORK_VERSION}/${PRODUCT_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "prefPane" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Contents/MacOS/${EXECUTABLE_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "menu" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Contents/MacOS/${EXECUTABLE_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "plugin" ]; then
  BINARY="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}/Contents/MacOS/${EXECUTABLE_NAME}"
elif [ "${WRAPPER_EXTENSION}" = "" ]; then
  BINARY="${TARGET_BUILD_DIR}/${EXECUTABLE_NAME}"
else
  builtin echo ":: error: unknown wrapper extension ${WRAPPER_EXTENSION}"
  exit 1
fi

BASENAME=$(/usr/bin/basename "${BINARY}")

builtin echo "Extracting architecures into thin binaries"
/usr/bin/lipo "${BINARY}" -thin ppc -output "${BINARY}_ppc_unstripped"
/usr/bin/lipo "${BINARY}" -thin i386 -output "${BINARY}_i386_unstripped"

builtin echo "Stripping thin binaries"
/usr/bin/strip -S -x -r -o "${BINARY}_ppc_stripped" -r "${BINARY}_ppc_unstripped"
/usr/bin/strip -S -x -r -o "${BINARY}_i386_stripped" -r "${BINARY}_i386_unstripped"

# as of Xcode Tools 2.3, atos is capable of working with Universal Binaries, so keep an unstripped Universal
builtin echo "Moving unstripped Universal Binary to target build directory for use with atos(1)"
/bin/mv -f "${BINARY}" "${TARGET_BUILD_DIR}/${BASENAME}_unstripped"

builtin echo "Making new (stripped) Universal Binary from stripped thin binaries"
/usr/bin/lipo -arch ppc "${BINARY}_ppc_stripped" -arch i386 "${BINARY}_i386_stripped" -create -output "${BINARY}"

builtin echo "Disposing of stripped thin binaries"
/bin/rm -f "${BINARY}_ppc_stripped"
/bin/rm -f "${BINARY}_i386_stripped"

builtin echo "Disposing of unstripped thin binaries"
/bin/rm -f "${BINARY}_ppc_unstripped"
/bin/rm -f "${BINARY}_i386_unstripped"

builtin echo "$0: Done"
exit 0