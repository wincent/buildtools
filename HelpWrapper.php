#!/usr/bin/php
<?php
  #
  # HelpWrapper.php
  # buildtools
  #
  # Created by Wincent Colaiuta on 06 December 2004.
  #
  # Copyright 2004-2006 Wincent Colaiuta.
  # This program is distributed in the hope that it will be useful, but WITHOUT
  # ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
  # FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
  # in the accompanying file, "LICENSE.txt", for more details.
  #
  
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