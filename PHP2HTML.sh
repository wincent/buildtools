#!/bin/bash
#
# PrepareHelp.sh
# buildtools
#
# Created by Wincent Colaiuta on 06/12/04.
#
# Copyright 2004-2006 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: PHP2HTML.sh 21 2006-08-09 21:52:10Z wincent $

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Defaults
#

#PHP="/usr/bin/php"
PHP="${BUILDTOOLS_DIR}/HelpWrapper.php"

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 php-file [global-include-file]"
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  PHP_FILE=$1
elif [ $# -eq 2 ]; then
  PHP_FILE="$1"
  GLOBAL_INCLUDE_FILE="$2"
else
  printusage
  exit 1
fi

HTML_FILE=`echo -n "${PHP_FILE}" | sed -e "s/\.php$/.html/"`
if [ ! -f "${HTML_FILE}" ]; then
  builtin echo "Parsing PHP input file ${PHP_FILE}; output file is ${HTML_FILE}"
  
  # explicitly trap errors because if this script is called using find -exec the errors may go unnoticed
  # (find just continues executing for each found file)
  "${PHP}" "${PHP_FILE}" "${GLOBAL_INCLUDE_FILE}" > "${HTML_FILE}" || ERROR="PHP returned non-zero exit code"
  if [ "${ERROR}" = "" ]; then
    builtin echo "Deleting processed input file ${PHP_FILE}"
    rm "${PHP_FILE}"
  else
    err "${ERROR}: see output file for details (${HTML_FILE})"
    exit 1
  fi
else
  warn "file ${HTML_FILE} already exists; skipping conversion of ${PHP_FILE}"
fi

builtin echo "$0: Done"
exit 0
