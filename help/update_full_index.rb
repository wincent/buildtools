#!/usr/bin/env ruby
# Copyright 2010 Wincent Colaiuta. All rights reserved.
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

require 'fileutils'

input_path  = 'pages/full_index.tmpl'
output_path = 'pages/full_index.tmpl.new'
output      = File.new output_path, 'w'

File.open input_path do |input|
  # read up to start marker, copying lines into output file
  while line = input.readline
    output.puts line
    break if line =~ /\A\s*## -- index items start -- ##\s*\z/
  end

  # insert new index items
  $stdin.each_line { |line| output.puts line }

  # skip over old index items
  while line = input.readline
    if line =~ /\A\s*## -- index items end -- ##\s*\z/
      output.puts line
      break
    end
  end

  # copy remaining lines from old file to new file
  begin
    while line = input.readline
      output.puts line
    end
  rescue EOFError
  end
end

FileUtils.mv output_path, input_path
