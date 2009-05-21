#!/bin/sh
# PreprocessInfoPlistStrings.sh
# buildtools
#
# Copyright 2003-2009 Wincent Colaiuta. All rights reserved.
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
for LANGUAGE in $(find . -name "*.lproj" -maxdepth 1)
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
    builtin echo "Preprocessing ${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
    "${GLOT}" --info    "${RESOURCES}/${PLIST_PATH}/Info.plist"       \
              --strings "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"  \
              --output  "${RESOURCES}/${LANGUAGE}/InfoPlist.strings"
  fi
done

builtin echo "$0: Done"
exit 0
