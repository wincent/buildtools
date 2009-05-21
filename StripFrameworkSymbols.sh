#!/bin/sh
# StripFrameworkSymbols.sh
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
