#!/bin/sh -e
# git-src-archive.sh
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

# prep source archive
git archive $TAGGED > "$BUILT_PRODUCTS_DIR/$PROJECT-$TAGGED-src.tar"

# add submodules to archive
git ls-tree $TAGGED | grep '^160000 ' | \
while read mode type sha1 path
do
  rm -rf "$PROJECT_TEMP_DIR/$PROJECT-$TAGGED-$path-src/$path"
  mkdir -p "$PROJECT_TEMP_DIR/$PROJECT-$TAGGED-$path-src/$path"
  (cd $path && git archive $sha1 | tar -xf - -C "$PROJECT_TEMP_DIR/$PROJECT-$TAGGED-$path-src/$path")
  tar -rf "$BUILT_PRODUCTS_DIR/$PROJECT-$TAGGED-src.tar" \
       -C "$PROJECT_TEMP_DIR/$PROJECT-$TAGGED-$path-src" $path
done
bzip2 -f "$BUILT_PRODUCTS_DIR/$PROJECT-$TAGGED-src.tar"
