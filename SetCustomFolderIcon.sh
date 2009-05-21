#!/bin/sh
# SetCustomFolderIcon.sh
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
FOLDER="${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}"

#
# Functions
# 
printusage()
{
  builtin echo 'Usage: $0 icon.icns [folder]'
  builtin echo 'If "folder" is omitted "${TARGET_BUILD_DIR}/${FULL_PRODUCT_NAME}" is assumed'
}
 
#
# Main
#

set -e

# process arguments
if [ $# -eq 2 ]; then
  FOLDER="$2"
elif [ $# -gt 2 -o $# -lt 1 ]; then
  printusage
  exit 1
fi
ICON="$1"

if [ ! -f "${ICON}" ]; then
  err "icns file ${ICON} not found"
  exit 1
fi

if [ ! -d "${FOLDER}" ]; then
  err "directory ${FOLDER} not found"
  exit 1
fi

builtin echo "Applying custom icon ${ICON} to folder ${FOLDER}"
wincent-icon-util -icon "${ICON}" -folder "${FOLDER}"

builtin echo "$0: Done"
exit 0

