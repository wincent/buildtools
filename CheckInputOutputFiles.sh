#!/bin/sh
#
# CheckInputOutputFiles.sh
# buildtools
#
# Created by Wincent Colaiuta on 06 December 2004.
#
# Copyright 2004-2008 Wincent Colaiuta.
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

set -e

# process environment variables
if [ ${SCRIPT_INPUT_FILE_COUNT} -lt 1 -o ${SCRIPT_OUTPUT_FILE_COUNT} -lt 1 ]; then
  builtin echo "No Input/Output files specified. Exiting."
  exit 0
fi

# find out the newest input file
NEWEST_INPUT=$SCRIPT_INPUT_FILE_0
builtin echo "Checking modification date for input file $SCRIPT_INPUT_FILE_0"

for (( FILE_COUNT=1 ; $FILE_COUNT < $SCRIPT_INPUT_FILE_COUNT ; FILE_COUNT++ ))
do
  FILE=$(declare -p SCRIPT_INPUT_FILE_$FILE_COUNT | awk -F "=" '{print $2}' | sed -e 's/"$//' -e 's/^"//')
  builtin echo "Checking modification date for input file ${FILE}"
  if [ "$FILE" -nt "$NEWEST_INPUT" ]; then
    NEWEST_INPUT=$FILE
  fi
done

# find out the oldest output file
if [ ! -e "$SCRIPT_OUTPUT_FILE_0" ]; then
  builtin echo "Output file $SCRIPT_OUTPUT_FILE_0 does not exist; aborting and returning 1"
  return 1
fi
  
OLDEST_OUTPUT=$SCRIPT_OUTPUT_FILE_0
builtin echo "Checking modification date for output file $SCRIPT_OUTPUT_FILE_0"

for (( FILE_COUNT=1 ; $FILE_COUNT < $SCRIPT_OUTPUT_FILE_COUNT ; FILE_COUNT++ ))
do
  FILE=$(declare -p SCRIPT_OUTPUT_FILE_$FILE_COUNT | awk -F "=" '{print $2}' | sed -e 's/"$//' -e 's/^"//')
  if [ -e "${FILE}" ]; then 
    builtin echo "Checking modification date for output file ${FILE}"
    if [ "$FILE" -ot "$OLDEST_OUTPUT" ]; then
      OLDEST_OUTPUT=$FILE
    fi
  else
    builtin echo "Output file $FILE does not exist; aborting and returning 1"
    return 1
  fi
done

if [ "$NEWEST_INPUT" -nt "$OLDEST_OUTPUT" ]; then
  builtin echo "Newest input file is newer than oldest output file: returning 1"
  return 1
else
  builtin echo "Newest input file is not newer than oldest output file: returning 0"
  return 0
fi

