[![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg?style=flat)](https://github.com/emcrisostomo/bitbucket-utils/blob/master/LICENSE)

BitBucket Utils
===============

`bb` is a small wrapper around BitBucket's RESTful API that currently provides
the following features:

  * List repositories of a user.
  * List repository URLs.
  * Filter repository names using a regular expression.
  * Filter repository URL using a regular expression.
  * Filter repositories by SCM type.

Prerequisites
-------------

`bb` requires the following programs to be present on the `${PATH}`:

  * `zsh`
  * `curl`
  * `jq`

Getting BitBucket Utils
-----------------------

A user who whishes to build `bb` should get a [release tarball][release].  A
release tarball contains everything a user needs to build `bb` on his system,
following the instructions detailed in the Installation section below and the
`INSTALL` file.

A developer who wishes to modify `bb` should get the sources (either from a
source tarball or cloning the repository) and have the GNU Build System
installed on his machine.  Please read `README.gnu-build-system` to get further
details about how to bootstrap `bb` from sources on your machine.

Getting a copy of the source repository is not recommended unless you are a
developer, you have the GNU Build System installed on your machine, and you know
how to bootstrap it on the sources.

[release]: https://github.com/emcrisostomo/bitbucket-utils/releases

Installation
------------

See the `INSTALL` file for detailed information about how to configure and
install `bb`.

Configuration
-------------

`bb` needs certain information when invoking the BitBucket API such as:

  * The credentials to use.
  * The repository *owner*.

`bb` can obtain this information in the following ways:

  * From the user configuration file, `~/.bb.conf`.
  * From global options, such as `-p` and `-u`.
  * From command options, such as `-o`.
  * From environment variables, such as `${REPO_OWNER}`.

A user will typicall store its BitBucket credentials in `~/.bb.conf`, which is
sourced during `bb` initialization, or set on the user environment by any other
mean.  The available variables are the following:

  * `BITBUCKET_USER`: the optional BitBucket user used during authenticated API
    calls with.  If not specified, an anonymous API call is performed.
  * `BITBUCKET_PASS`: the optional BitBucket user password, used only if
    `BITBUCKET_USER` is specified.

Usage
-----

The syntax to invoke `bb` is the following:

    $ bb (global_options)* command (options)*

The available global options are:

  * `-u`: to specify the BitBucket user.
  * `-p`: to specify the BitBucket user password.

The available commands and their subcommands are:

  * `help`
  * `repo`
    - `help`
    - `list`
    - `update`

Examples
--------

The following command lists the repositories of the current user:

    $ bb repo list

The following command lists the repositories URL of the current user:

    $ bb repo list -u

The following command lists the Mercurial repositories whose name starts with
`prefix`:

    $ bb repo list -n ^prefix -t hg

Bug Reports
-----------

Bug reports can be sent directly to the authors.

-----

Copyright (c) 2015 Enrico M. Crisostomo

This program is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation; either version 3, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A
PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>.
