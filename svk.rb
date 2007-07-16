#!/usr/bin/env ruby
# svk.rb
# buildtools
#
# Created by Wincent Colaiuta on 25 March 2007.
# Copyright 2007 Wincent Colaiuta.
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
# in the accompanying file, "LICENSE.txt", for more details.
#
# $Id: svk.rb 62 2007-03-26 11:04:26Z wincent $

module SVK
  
  def self.print_rev_number
    puts get_rev_number
  end
  
  def self.get_rev_number
    
    # get the remote revision number
    info = command('svk info').find { |line| not (line =~ /^Mirrored From: .+ Rev\. (\d+)$/).nil? }
    raise 'No revision number' if info.nil?
    rev = $~[1]
    
    # append "+" if there are local modifications
    rev = "#{rev}+" if (command('svk status').split.length > 0)
    
    rev
    
  end
  
private
  
  def self.command(string)
    begin
      `#{string}`
    ensure
      raise 'Non-zero exit status' unless $? == 0
    end
  end
  
end # module SVK

SVK::print_rev_number if __FILE__ == $0
