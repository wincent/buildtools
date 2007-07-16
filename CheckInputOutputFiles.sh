#!/bin/bash
#
# CheckInputOutputFiles.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
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

# A script to work around Xcode Input/Output file bugs (dependency checking broken)

#
# Main
#

# TODO: replace manual mod date checks with test's -ot (older than) and -nt (newer than) primaries

set -e

# process environment variables
if [ ${SCRIPT_INPUT_FILE_COUNT} -lt 1 -o ${SCRIPT_OUTPUT_FILE_COUNT} -lt 1 ]; then
  builtin echo "No Input/Output files specified. Exiting."
  exit 0
fi

NEWEST_INPUT=`/usr/bin/stat -f "%m" "${SCRIPT_INPUT_FILE_0}"`
builtin echo "Checking modification date for input file ${SCRIPT_INPUT_FILE_0}: ${NEWEST_INPUT}"

for (( FILE_COUNT=1 ; ${FILE_COUNT} < ${SCRIPT_INPUT_FILE_COUNT}; FILE_COUNT++ ))
do
  FILE=$(declare -p SCRIPT_INPUT_FILE_$FILE_COUNT | /usr/bin/awk -F "=" '{print $2}' | /usr/bin/sed -e 's/"$//' -e 's/^"//')
  FILE_MOD_DATE=`/usr/bin/stat -f "%m" "${FILE}"`
  builtin echo "Checking modification date for input file ${FILE}: ${FILE_MOD_DATE}"
  if [ ${FILE_MOD_DATE} -gt ${NEWEST_INPUT} ]; then
    NEWEST_INPUT=${FILE_MOD_DATE}
  fi
done

if [ ! -e "${SCRIPT_OUTPUT_FILE_0}" ]; then
  builtin echo "Output file ${SCRIPT_OUTPUT_FILE_0} does not exist; aborting and returning 1"
  return 1
fi
  
OLDEST_OUTPUT=`/usr/bin/stat -f "%m" "${SCRIPT_OUTPUT_FILE_0}"`
builtin echo "Checking modification date for output file ${SCRIPT_OUTPUT_FILE_0}: ${NEWEST_OUTPUT}"

for (( FILE_COUNT=1 ; ${FILE_COUNT} < ${SCRIPT_OUTPUT_FILE_COUNT}; FILE_COUNT++ ))
do
  FILE=$(declare -p SCRIPT_OUTPUT_FILE_$FILE_COUNT | /usr/bin/awk -F "=" '{print $2}' | /usr/bin/sed -e 's/"$//' -e 's/^"//')
  if [ -e "${FILE}" ]; then 
    FILE_MOD_DATE=`/usr/bin/stat -f "%m" "${FILE}"`
    builtin echo "Checking modification date for output file ${FILE}: ${FILE_MOD_DATE}"
    if [ ${FILE_MOD_DATE} -lt ${OLDEST_OUTPUT} ]; then
      OLDEST_OUTPUT=${FILE_MOD_DATE}
    fi
  else
    builtin echo "Output file ${FILE} does not exist; aborting and returning 1"
    return 1
  fi
done

if [ ${NEWEST_INPUT} -gt ${OLDEST_OUTPUT} ]; then
  builtin echo "Newest input file is newer than oldest output file: returning 1"
  return 1
else
  builtin echo "Newest input file is not newer than oldest output file: returning 0"
  return 0
fi

