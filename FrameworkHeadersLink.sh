#!/bin/bash
#
# FrameworkHeadersLink.sh
# buildtools
#
# Created by Wincent Colaiuta on 26 October 2006.
#
# Copyright 2004-2006 Wincent Colaiuta.
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
