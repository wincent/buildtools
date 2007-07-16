#!/usr/bin/php
<?php
  #
  # HelpWrapper.php
  # buildtools
  #
  # Created by Wincent Colaiuta on 06 December 2004.
  #
  # Copyright 2004-2006 Wincent Colaiuta.
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
  
  # usage:
  # HelpWrapper.php file-to-be-wrapped [global-include-file]
  
  if ($argc == 2)
  {
    $wrapped    = $argv[1];
    $in_dir     = dirname($wrapped);
    $global_inc = $in_dir . "/global.inc.php";
    if (file_exists($global_inc))
    {
      include $global_inc;
    }
    include $wrapped;
  }
  elseif ($argc == 3)
  {
    $wrapped    = $argv[1];
    $global_inc = $argv[2];
    include $global_inc;
    include $wrapped;
  }
?>