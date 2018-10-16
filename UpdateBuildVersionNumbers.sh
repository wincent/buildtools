#!/bin/sh
# UpdateBuildVersionNumbers.sh
# buildtools
#
# Copyright 2003-present Greg Hurrell. All rights reserved.
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

# The following macro definition is updated, if present:
#
#    /* START: Auto-updated macro definitions */
#
#    #define WO_COPYRIGHT_YEAR  2003-2004
#
#    /* END: Auto-updated macro definitons */
#
# The file containing the versioning information should not be updated by hand
# because its content is "brittle" and changing it may prevent this script from
# updating the information.

# NOTE: If info plist preprocessing is turned on in Xcode, it happens *before* any shell scripts get run.
# Must therefore call this script from a separate target *before* building the main target.

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 version-file"
}

update_copyright_years()
{
  builtin echo "Updating WO_COPYRIGHT_YEAR entry"

  # get current year
  YEAR=$(date +%Y)

  # in the line : #define WO_COPYRIGHT_YEAR ... update: "... XXXX ..."
  cat "${SOURCE_ROOT}/${WO_VERSION_FILE}" | sed \
    -e "/^#define[ ][ ]*WO_COPYRIGHT_YEAR[ ]/s/\(.*\)[0-9]\{4\}\([^\-]*\)/\1${YEAR}\2/" \
    > "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp"

  if [ $? -eq 0 ]; then

    # only copy the file if it's actually different
    if compare "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp" "${SOURCE_ROOT}/${WO_VERSION_FILE}"; then
      cp -fv "${SOURCE_ROOT}/${WO_VERSION_FILE}.temp" \
             "${SOURCE_ROOT}/${WO_VERSION_FILE}"
    fi

  else
    err "non-zero exit status during copyright update"
    exit 1
  fi
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  WO_VERSION_FILE="$1"
else
  printusage
  exit 1
fi

# Backup old version of file
close "${WO_VERSION_FILE}"
builtin echo "Making backup of ${WO_VERSION_FILE}"

cp -fv "${SOURCE_ROOT}/${WO_VERSION_FILE}" \
       "${SOURCE_ROOT}/${WO_VERSION_FILE}.bak"

# Scan for copyright and update
update_copyright_years

# ensure all pending writes flushed to disk
sync

builtin echo "$0: Done"
