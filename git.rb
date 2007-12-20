#!/usr/bin/env ruby
# git.rb
# buildtools
#
# Created by Wincent Colaiuta on 12 August 2007.
# 
# Copyright 2007 Wincent Colaiuta.
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

module Git
  def self.get_rev_number
    rev = command('git rev-parse --short HEAD')
    raise "'#{rev}' is not a valid revision number" unless rev =~ /\A[a-f0-9]{7}[a-f0-9]*\z/

    # append "+" if there are local modifications
    `git diff --quiet`
    rev << '+' if $?.exitstatus != 0
    rev
  end

private

  # Runs the command passed in via string.
  # Returns the output from the command with any trailing newline stripped.
  # Raises an exception if the command has a non-zero exit status.
  def self.command(string)
    `#{string}`.chomp
  ensure
    raise "non-zero exit status (#{$?.exitstatus}) for command: #{string}" if $?.exitstatus != 0
  end

end # module Git
