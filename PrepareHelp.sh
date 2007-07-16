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

. "${BUILDTOOLS_DIR}/Common.sh"

#
# Defaults
#

# really need to call this script once for each language:
#FOLDER="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}/en.lproj/${PRODUCT_NAME} Help"
INDEXER_PATH="/Developer/Applications/Utilities/Help Indexer.app/Contents/MacOS"
INDEXER="Help Indexer"

#
# Functions
#

printusage()
{
  builtin echo "Usage: $0 help-folder"
}

#
# Main
#

set -e

# process arguments
if [ $# -eq 1 ]; then
  FOLDER="$1"
else
  printusage
  exit 1
fi

# if global.inc.php file exists, pass it to wrapper
if [ -f "${FOLDER}/global.inc.php" ]; then
  GLOBAL_INCLUDE_FILE="${FOLDER}/global.inc.php"
fi

# run PHP files through PHP; based on idea at http://www.zathras.de/angelweb/x2005-04-18.htm
builtin echo "Beginning PHP to HTML conversion for folder ${FOLDER}"
find "${FOLDER}" -name "*.php" -not -name "*.inc.php" -exec "${BUILDTOOLS_DIR}/PHP2HTML.sh" "{}" "${GLOBAL_INCLUDE_FILE}" \;

builtin echo "Deleting PHP include files"
find "${FOLDER}" -name "*.inc.php" -delete -print

builtin echo "Converting links in folder: ${FOLDER}"
find "${FOLDER}" -name "*.html" -print -exec \
  perl -pi -e 's/(<a [^>]*href\s*=\s*")([^":]+)(\.php)(#[^"]*)?("[^>]*>)/\1\2\.html\4\5/gi' {} \;

builtin echo "Running Apple Help Indexer"

"${INDEXER_PATH}/${INDEXER}" "${FOLDER}" -PantherIndexing NO -TigerIndexing YES -GenerateSummaries YES -IndexAnchors YES

builtin echo "$0: Done"
exit 0
