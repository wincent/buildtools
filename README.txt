BUILDTOOLS INTRODUCTION

The Wincent Buildtools (from here on referred to as "buildtools") is a
collection of scripts, tools and configuration files used in the build
processes of a number of Wincent products (for a full product listing see
http://wincent.com/). buildtools is licensed under the simplified BSD
license (see the file, LICENSE.txt).

I maintain these tools as a separate package for two reasons: firstly, because
they allow frequently-used tools and configuration information to be stored in
a central location rather than replicated across projects, and secondly,
because I wanted to release the source code to some software I was developing
under the GPL (specifically, WOTest; see: http://test.wincent.com), so it made
sense to release the toolset required to build the software under the same
terms.

There are two non-standard executables that some buildtools scripts depend on
(they expect to find them in the PATH), "wincent-strings-util" and
"wincent-icon-util". The former, Wincent Strings Utility, is a separate
project, licensed under the GPL. More information can be obtained from the
project website: http://strings.wincent.com/. The latter, Wincent Icon Utility,
is also a separate project licensed under the GPL but there is no project
website for it at the moment.


SOURCE CODE REPOSITORY

The official buildtools Git repository can be cloned using:

  git clone git://git.wincent.com/buildtools.git

A web-based repository browser can be explored at:

  http://git.wincent.com/buildtools.git

At the time of writing, there are three branches in the repository:

  - master: cutting edge development corresponding to the latest version of Mac
    OS X (currently Mac OS X 10.6 Snow Leopard)
  - maint: stable development line, usually only a few commits behind "master"
  - leopard: maintenance branch, unlikely to receive many updates

As buildtools serves as support for other products, buildtools "releases" as
such are never tagged. You will, however, find tags such as "Synergy-3.5a5"
which are used to record which version of buildtools was used to build the
other product.


DONATIONS

These buildtools are provided free of charge under the terms of the BSD
license. If they are useful to you please consider visiting the website and
making a donation:

  http://wincent.com/a/products/buildtools/


INSTRUCTIONS FOR USE

The purpose and operation of most of the scripts are self-explanatory. The
scripts have been designed for use with Wincent projects and require a specific
filesystem layout (as described below). Use with Wincent projects should be
straightforward; use in other contexts may require modifications to be made.


ABOUT THE FILESYSTEM LAYOUT

These buildtools are designed to work with multiple projects sharing a common
directory structure, including a shared built products directory and a shared
build intermediates directory. The base layout used by Wincent consists of the
following directories at the topmost level:

  build
  build-intermediates

Project folders also sit at the topmost level. Most Wincent products use the
following layout for project folders:

  Project/src
  Project/extra

Files checked out from the repository (generally all those necessary to build
the project) are stored in the "src" subdirectory. All other ancillary
materials (generally nothing necessary to build the project), if any, are
stored in the "extra" subdirectory.

The buildtools themselves are generally included in each project via the Git
submodule mechanism, inside the "src" folder for the project:

  Project/src/buildtools

This layout ensures that all projects have the same relative paths to the build
and build-intermediates directories; that is, from the "src" directory of each
project the relative paths are:

  ../../build
  ../../build-intermediates


AUTHOR

Wincent Colaiuta
http://wincent.com/                 (company website)
http://colaiuta.net/                (personal weblog)
http://wincent.com/a/contact/mail/  (contact page)
