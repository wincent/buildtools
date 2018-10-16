#!/bin/sh
# StripDSYM.sh
# buildtools
#
# Copyright 2004-present Greg Hurrell. All rights reserved.
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
