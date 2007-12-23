#!/bin/bash
#
# PreprocessInfoPlistStrings.sh
# buildtools
#
# Created by Wincent Colaiuta on Fri Dec 30 2003.
# 
# Copyright 2003-2007 Wincent Colaiuta.
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
# Defaults
#

GLOT="wincent-strings-util"

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 resources-folder"
  builtin echo "Where: \"resources-folder\" contains your lproj folders"
}

#
# Main
#

set -e

# process arguments
if [ $# -ne 1 ]; then
  printusage
  exit 1
fi
RESOURCES="$1"

cd "${RESOURCES}"
for LANGUAGE in `/usr/bin/find . -name "*.lproj" -maxdepth 1`
do
  builtin echo "Preprocessing language: ${LANGUAGE}"
  
  # kludge: Info.plist is stored in different places depending on the bundle type
  if [ "${WRAPPER_EXTENSION}" = "app" ]; then
    PLIST_PATH=".."
  elif [ "${WRAPPER_EXTENSION}" = "bundle" ]; then
    PLIST_PATH=".."
  elif [ "${WRAPPER_EXTENSION}" = "framework" ]; then
    PLIST_PATH="."
  elif [ "${WRAPPER_EXTENSION}" = "prefPane" ]; then
    PLIST_PATH=".."
  elif [ "${WRAPPER_EXTENSION}" = "menu" ]; then
    PLIST_PATH=".."
  else
    err "unknown wrapper extension ${WRAPPER_EXTENSION}"
    exit 1
  fi
  
  # wincent-strings-util will bail for non-existent merge files
  if [ ! -f "${RESOURCES}/${LANGUAGE}/InfoPlist.strings" ]; then
    warn "${RESOURCES}/${LANGUAGE}/InfoPlist.strings does not exist"
  else
    builtin echo "Prepocessing ${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
    "${GLOT}" --info    "${RESOURCES}/${PLIST_PATH}/Info.plist"       \
              --strings "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"  \
              --output  "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
  fi
done

builtin echo "$0: Done"
exit 0
