#!/bin/sh
# FrameworkHeadersLink.sh
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
# Main
#

set -e

cd "${TARGET_BUILD_DIR}"

if [ -L "${PRODUCT_NAME}" ]; then
  builtin echo "Symbolic link already exists at: ${TARGET_BUILD_DIR}/${PRODUCT_NAME}, removing it"
  rm "${PRODUCT_NAME}"
fi

if [ -f "${PRODUCT_NAME}" -o -d "${PRODUCT_NAME}" ]; then
  err "File or folder already exists at: ${TARGET_BUILD_DIR}/${PRODUCT_NAME}"
  exit 1
fi

builtin echo "Creating symbolic link at: ${TARGET_BUILD_DIR}/${PRODUCT_NAME}"

# a relative path would be nicer but this will have to do for now
ln -s -v "${SOURCE_ROOT}" "${PRODUCT_NAME}"

cd -

builtin echo "$0: Done"
exit 0
