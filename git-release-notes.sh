#!/bin/sh -e
# git-release-notes.sh
# buildtools
#
# Copyright 2007-2010 Wincent Colaiuta. All rights reserved.
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

# Xcode will ignore the shebang line, making the -e above ineffective
set -e

TAGGED=$($BUILDTOOLS_DIR/git-check-tag.sh)
PREV_TAG=$($BUILDTOOLS_DIR/git-last-tag.sh)
test -n "$PREV_TAG" || die 'no value for PREV_TAG'

NOTES="$BUILT_PRODUCTS_DIR/$PROJECT-$TAGGED-release-notes.txt"
DETAILED_NOTES="$BUILT_PRODUCTS_DIR/$PROJECT-$TAGGED-detailed-release-notes.txt"
echo "Changes from $PREV_TAG to $TAGGED:" > $NOTES
echo "" >> $NOTES
git log --no-decorate --pretty=format:'    %s' $PREV_TAG..$TAGGED >> $NOTES

echo "Changes from $PREV_TAG to $TAGGED:" > $DETAILED_NOTES
echo "" >> $DETAILED_NOTES
git log --no-decorate $PREV_TAG..$TAGGED >> $DETAILED_NOTES

# append submodule notes
git ls-tree $TAGGED | grep '^160000 ' | \
while read mode type sha1 path
do
  LAST_REF=$(git ls-tree $PREV_TAG | grep '^160000 ' | grep $path | awk '{ print $3 }')
  SUBMODULE_NOTES=$(cd $path && git log --no-decorate --pretty=format:'    %s' $LAST_REF..$sha1)
  DETAILED_SUBMODULE_NOTES=$(cd $path && git log --no-decorate $LAST_REF..$sha1)
  if [ $(echo "$SUBMODULE_NOTES" | wc -l) -ne 1 ]; then
    echo "" >> $NOTES
    echo "" >> $NOTES
    echo "$path (submodule): " >> $NOTES
    echo "" >> $NOTES
    echo "$SUBMODULE_NOTES" >> $NOTES

    echo "" >> $DETAILED_NOTES
    echo "--------------------------------------------------------------------------------" >> $DETAILED_NOTES
    echo "" >> $DETAILED_NOTES
    echo "$path (submodule): " >> $DETAILED_NOTES
    echo "" >> $DETAILED_NOTES
    echo "$DETAILED_SUBMODULE_NOTES" >> $DETAILED_NOTES
  fi
done
