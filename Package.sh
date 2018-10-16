#!/bin/sh
# Package.sh
# buildtools
#
# Copyright 2007-present Greg Hurrell. All rights reserved.
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
# Functions
#

printusage()
{
  builtin echo "Usage: $0 [output-package-name [package-maker-document]]"
  builtin echo 'If "output-package-name" is omitted "${PRODUCT_NAME}.pkg" is assumed'
  builtin echo 'If "package-maker-document" is omitted "installation-package.pmdoc" is assumed'
}

#
# Main
#

set -e

# process arguments
if [ $# -gt 2 ]; then
  printusage
  exit 1
fi

if [ $# -gt 1 ]; then
  PKG_DOC="$2"
else
  PKG_DOC="${SOURCE_ROOT}/installation-package.pmdoc"
fi

if [ $# -gt 0 ]; then
  TARGET_PATH="${TARGET_BUILD_DIR}/$1"
else
  if [ -z "${PRODUCT_NAME}" ]; then
    err "PRODUCT_NAME empty and no explicit output-package-name supplied"
    exit 1
  fi
  TARGET_PATH="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.pkg"
fi

builtin echo "Running packagemaker:"
"${DEVELOPER_BIN_DIR}/packagemaker" --doc "${PKG_DOC}" --out "${TARGET_PATH}" --verbose
builtin echo "$0: Done"
exit 0
