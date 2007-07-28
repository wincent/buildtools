#!/bin/bash
#
# Package.sh
# buildtools
#
# Created by Wincent Colaiuta on 28 July 2007.
#
# Copyright 2007 Wincent Colaiuta.
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
  TARGET_PATH="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.pkg"
fi

builtin echo "Running packagemaker:"
"${DEVELOPER_BIN_DIR}/packagemaker" --doc "${PKG_DOC}" --out "${TARGET_PATH}" --verbose
builtin echo "$0: Done"
exit 0
