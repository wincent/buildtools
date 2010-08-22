#!/usr/bin/env ruby
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

# This is a simple script that greps through all the files in the current
# working directory looking for strings which match:
#
#     #set $page_title  = 'Force Quitting Hextrapolate'
#     #set $tag         = 'force_quitting'
#
# And turning them into:
#
#     $index_item($link_to('force_quitting', 'Force Quitting Hextrapolate'))

require 'pathname'

class TemplateScanner
  def initialize
    @title_tag_pairs = {}
    process_directory(Pathname.getwd)

    # sort on the title page, ignoring first and last characters (quote marks)
    @title_tag_pairs.sort { |a, b| a[1][1..-2] <=> b[1][1..-2] }.each do |item|
      puts "$index_item($link_to(#{item[0]}, #{item[1]}))"
    end
  end

  def process_directory(dir)
    dir.children.each do |child|
      if child.directory?
        process_directory(child) # recurse
      else
        process_template(child) if child.extname == '.tmpl'
      end
    end
  end

  def process_template(template)
    content = template.read
    return unless content =~ /#set\s+\$page_title\s*=\s*(['"].+?['"])\s*$/
    page_title = $~[1]
    return unless content =~ /#set\s+\$tag\s*=\s*(['"].+?['"])\s*$/
    tag = $~[1]
    @title_tag_pairs[tag] = page_title
  end
end # class TemplateScanner

if __FILE__ == $0
  TemplateScanner.new
end
