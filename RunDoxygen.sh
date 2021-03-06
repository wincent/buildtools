#!/bin/sh
# RunDoxygen.sh
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

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Defaults
#
DOXYFILE="${SOURCE_ROOT}/Doxyfile"
#DOXYGEN="doxygen"
DOXYGEN="/Applications/Doxygen.app/Contents/Resources/doxygen"

#
# Functions
#
printusage()
{
  builtin echo 'Usage: $0 [Doxyfile]'
  builtin echo 'If "Doxyfile" is omitted "${SOURCE_ROOT}/Doxyfile" is assumed' 
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  DOXYFILE="$1"
elif [ $# -gt 1 ]; then
  printusage
  exit 1
fi

# issue error message if Doxygen not installed
if [ ! -f "${DOXYGEN}" ]; then
  err "${DOXYGEN} not found"
  exit 1
fi

cd "${SOURCE_ROOT}"
builtin echo "Running Doxygen:"
"${DOXYGEN}" "${DOXYFILE}"
builtin echo "$0: Done"
cd -

exit 0
