#!/bin/sh
#
# StripDSYM.sh
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

# This is a modified version of the Strip.sh script designed to work when using dSYM files. Key points:
# - stripping must occur only after the dSYM file has been produced
#    http://lists.apple.com/archives/Xcode-users/2006/May/msg00855.html
# - DEBUG_INFORMATION_FORMAT must be set to dwarf, not dwarf-with-dsym, otherwise Xcode will run dsymutil after stripping and fail

. "${BUILDTOOLS_DIR}/Common.sh"

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
BASENAME=$(basename "${BINARY}")

# dsymutil will issue a non-fatal warning if binary has already been stripped
builtin echo "Running dsymutil on unstripped binary"
if [[ $(dsymutil -o "${DWARF_DSYM_FOLDER_PATH}/${DWARF_DSYM_FILE_NAME}" "${BINARY}") =~ "warning" ]]; then
  warn "dsymutil complained (binary already stripped?); try doing a 'Clean' before doing a release build"
fi

builtin echo "Stripping binary"
strip -S -x -r "${BINARY}"

builtin echo "$0: Done"
exit 0
