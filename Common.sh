#!/bin/bash
#
# Common.sh
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
# Functions
#

# Xcode picks up lines echoed with this function and displays them as notes in the Build Results window.
note()
{
  builtin echo ":: note: $1"
}

# Xcode picks up lines echoed with this function and displays them as warnings in the Build Results window.
warn()
{
  builtin echo ":: warning: $1"
}

# Xcode picks up lines echoed with this function and displays them as errors in the Build Results window.
err()
{
  builtin echo ":: error: $1"
}

die()
{
  err "$1"
  exit 1
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
  WO_LAST_PATH_COMPONENT=`builtin echo $1 | /usr/bin/perl -p -e 's#.*/##'`
  
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
  end tell \n " | /usr/bin/osascript
}
