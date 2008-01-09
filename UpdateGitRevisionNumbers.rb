#!/usr/bin/env ruby
# UpdateGitRevisionNumbers.rb
# buildtools
#
# Created by Wincent Colaiuta on 12 August 2007.
# 
# Copyright 2007-2008 Wincent Colaiuta.
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

require File.join(File.dirname(__FILE__), 'git').to_s
require 'pathname'

target  = Pathname.new 'com.wincent.buildtools.gitrev.h'
rev     = Git::get_rev_number
date    = Time.new.to_s
output  = <<-HEADER

/*
  Autogenerated by UpdateGitRevisionNumbers.rb.
  This file should be ignored by an approriate entry in the .gitignore file.
 */

#define WO_BUILDNUMBER #{rev}
#define WO_BUILDDATE "#{date}"

HEADER

target.open('a+') do |file|
  # check existing contents of file, if any
  file.rewind
  while not file.eof?
    if file.readline =~ /^#define\s+WO_BUILDNUMBER\s+([a-f0-9]{7}\+?)/ and $~[1] == rev
      already_up_to_date = true
      break
    end
  end

  # will only actually modify the file if the revision number has changed
  # (avoids gratuitous rebuilds in Xcode)
  unless already_up_to_date
    file.rewind
    file.truncate 0
    file.print output
  end
end
