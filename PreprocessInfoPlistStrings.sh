#!/bin/bash
#
# PreprocessInfoPlistStrings.sh
# buildtools
#
# Created by Wincent Colaiuta on Fri Dec 30 2003.
# 
# Copyright 2003-2007 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: PreprocessInfoPlistStrings.sh 79 2007-07-16 14:10:46Z wincent $

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
    builtin echo ":: error: unknown wrapper extension ${WRAPPER_EXTENSION}"
    exit 1
  fi
  
  # wincent-strings-util will bail for non-existent merge files
  if [ ! -f "${RESOURCES}/${LANGUAGE}/InfoPlist.strings" ]; then
    builtin echo ":: warning: ${RESOURCES}/${LANGUAGE}/InfoPlist.strings does not exist"
  else
    builtin echo "Prepocessing ${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
    "${GLOT}" -info     "${RESOURCES}/${PLIST_PATH}/Info.plist"       \
              -strings  "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"  \
              -output   "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
  fi
done

builtin echo "$0: Done"
exit 0
