#!/bin/bash
#
# SetCustomFolderIcon.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
#
# Copyright 2004-2007 Wincent Colaiuta.
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
  builtin echo "error: icns file ${ICON} not found"
  exit 1
fi

if [ ! -d "${FOLDER}" ]; then
  builtin echo "error: directory ${FOLDER} not found"
  exit 1
fi

# see: http://cocoadev.com/index.pl?HowToSetACustomIconWithRez
builtin echo "Preparing icon from ${ICON}"
builtin echo "read 'icns' (-16455) \"${ICON}\";" | /Developer/Tools/Rez -o `/usr/bin/printf "${FOLDER}/Icon\r"` 

builtin echo "Setting custom icon attribute on ${FOLDER}"
/Developer/Tools/SetFile -a C "${FOLDER}"

builtin echo "$0: Done"
exit 0

