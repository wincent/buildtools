#!/bin/sh
# Common.sh
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

#
# Set-up
#

# Find out if terminal supports the following attributes (see terminfo(5)):
#   bold  : enter_bold_mode (turn on bold (extra bright) mode)
#   setaf : set_a_foreground (set the foreground color to the specified parameter)
#   sgr0  : exit_attribute_mode (turn off all attributes)
# When running under Xcode, the tput commands succeed even though color is not supported,
# but the test for the open file descriptor (-t 1) fails, thus enabling us to disable color.
test -z "$BUILDTOOLS_COLOR" &&
  test -t 1 &&
  tput bold > /dev/null 2>&1 &&
  tput setaf 1 > /dev/null 2>&1 &&
  tput sgr0 > /dev/null 2>&1 &&
  BUILDTOOLS_COLOR=true

if [ -n "$BUILDTOOLS_COLOR" ]; then
  BOLD="\033[1m"
  RESET="\033[0m"
fi

#
# Functions
#

# Xcode picks up lines echoed with this function and displays them as notes in the Build Results window.
note()
{
  builtin echo ":: note: $1" > /dev/stderr
}

# Xcode picks up lines echoed with this function and displays them as warnings in the Build Results window.
warn()
{
  builtin echo ":: warning: $1" > /dev/stderr
}

# Xcode picks up lines echoed with this function and displays them as errors in the Build Results window.
err()
{
  builtin echo ":: error: $1" > /dev/stderr
}

die()
{
  err "$1"
  exit 1
}

# returns 0 (success) if the two input files differ, 1 otherwise
compare()
{
  ! diff "$1" "$2" > /dev/null 2>&1
}

#
# Use AppleScript to instruct Xcode to close a file, allowing us to modify it.
#
# In older versions of Xcode, it complained if it detected external changes to an open file.
# As of 2.4 it appears that it automatically detects changed files when it becomes active 
# (after switching apps). It complains only if the changes conflict with edits made from
# inside Xcode.
#
close()
{
  builtin echo "Closing $1, if it is open"
  WO_LAST_PATH_COMPONENT=$(builtin echo "$1" | perl -p -e 's#.*/##')
  
  # only execute if Xcode is actually running (may not be if building using xcodebuild)
  builtin echo -e "                                                           \n\
                                                                              \n\
  tell application \"System Events\"                                          \n\
      if ((get name of the processes) contains \"Xcode\") then                \n\
          tell application \"Xcode\"                                          \n\
              try                                                             \n\
                  close document \"${WO_LAST_PATH_COMPONENT}\" saving ask     \n\
              end try                                                         \n\
          end tell
      end if
  end tell \n " | osascript
}
