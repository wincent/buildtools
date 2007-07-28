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
  builtin echo "Usage: $0 output-package-name [package-maker-document]"
  builtin echo 'If "package-maker-document" is omitted "installation-package.pmdoc" is assumed'
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 2 ]; then
  PKG_DOC="$2"
elif [ $# -gt 2 -o $# -lt 1 ]; then
  printusage
  exit 1
fi
PKG_NAME="$1"
PKG_DOC="${SOURCE_ROOT}/installation-package.pmdoc"
TARGET_PATH="${TARGET_BUILD_DIR}/${PKG_NAME}"

builtin echo "Running packagemaker:"
"${DEVELOPER_BIN_DIR}/packagemaker" --doc "${PKG_DOC}" --out "${TARGET_PATH}" --verbose
builtin echo "$0: Done"
exit 0
