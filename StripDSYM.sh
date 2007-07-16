#!/bin/bash
#
# StripDSYM.sh
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
# $Id: StripDSYM.sh 25 2006-09-06 09:44:10Z wincent $

# This is a modified version of the Strip.sh script designed to work when using dSYM files. Key points:
# - stripping must occur only after the dSYM file has been produced
#    http://lists.apple.com/archives/Xcode-users/2006/May/msg00855.html
# - DEBUG_INFORMATION_FORMAT must be set to dwarf, not dwarf-with-dsym, otherwise Xcode will run dsymutil after stripping and fail

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

BINARY="${TARGET_BUILD_DIR}/${EXECUTABLE_PATH}"
BASENAME=$(/usr/bin/basename "${BINARY}")

builtin echo "Running dsymutil on unstripped binary"
if ! $(/usr/bin/dsymutil -o "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}" "${BINARY}"); then
  builtin echo -e "\nwarning: dsymutil complained; try doing a 'Clean' before doing a release build"
fi

builtin echo "Extracting architecures into thin binaries"
/usr/bin/lipo "${BINARY}" -thin ppc -output "${BINARY}_ppc_unstripped"
/usr/bin/lipo "${BINARY}" -thin i386 -output "${BINARY}_i386_unstripped"

builtin echo "Stripping thin binaries"
/usr/bin/strip -S -x -r -o "${BINARY}_ppc_stripped" -r "${BINARY}_ppc_unstripped"
/usr/bin/strip -S -x -r -o "${BINARY}_i386_stripped" -r "${BINARY}_i386_unstripped"

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