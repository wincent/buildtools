#!/usr/bin/env ruby
## Created by Wincent Colaiuta on 12 April 2007
## Copyright 2007-2008 Wincent Colaiuta

=begin

This is a simple script that greps through all the files in the current working directory looking for strings which match:

#set $page_title  = 'Force Quitting Hextrapolate'
#set $tag         = 'force_quitting'

And turning them into:

$index_item($link_to('force_quitting', 'Force Quitting Hextrapolate'))

=end

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
