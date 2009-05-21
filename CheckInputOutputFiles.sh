#!/bin/sh
# CheckInputOutputFiles.sh
# buildtools
#
# Copyright 2004-2009 Wincent Colaiuta. All rights reserved.
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

