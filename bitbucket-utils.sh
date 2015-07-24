#!/bin/zsh
# -*- coding: utf-8; tab-width: 2; indent-tabs-mode: nil; sh-basic-offset: 2; sh-indentation: 2; -*- vim:fenc=utf-8:et:sw=2:ts=2:sts=2
#
# Copyright (C) 2015 Enrico M. Crisostomo
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
setopt local_options
setopt local_traps
unsetopt glob_subst

set -o errexit
set -o nounset

PROGNAME=${0:t}
PROGDIR=${0:h}

PROGRAMS=( jq curl )

check_health()
{
  for p in ${PROGRAMS}
  do
    command -v ${p} > /dev/null 2>&1 || {
      >&2 print -- Cannot find: ${p}
      exit 1
    }
  done
}

check_credentials()
{
  (( ${+BITBUCKET_USER} )) || {
    >&2 print -- Missing credentials.
    exit 4
  }

  (( ${+BITBUCKET_PASS} )) || {
    >&2 print -- Missing credentials.
    exit 4
  }
}

check_repository_vars()
{
  (( ${+REPO_OWNER} )) || {
    >&2 print -- Missing repository owner.
    exit 4
  }
}

print_usage()
{
  print -- "${PROGNAME}"
  print
  print -- "Usage:"
  print -- "${PROGNAME} (option)*"
  print
  print -- "Options:"
  print -- " -h     Show this help."
  print -- " -n     Specify a repository name pattern."
  print -- " -o     Specify the repository owner."
  print -- " -s     Specify the URL scheme."
  print -- " -u     Print repository URLs."
  print
  print -- "Report bugs to <enrico.m.crisostomo@gmail.com>."
}

print_names()
{
  for res in ${PAGES}
  do
    REPO_NAMES=( ${REPO_NAMES} $(echo ${res} | jq -r '.values[].name') )
  done

  for n in ${REPO_NAMES}
  do
    if [[ ${n} =~ ${REPO_PATTERN} ]]
    then
      print -- ${n}
    fi
  done
}

print_urls()
{
  for res in ${PAGES}
  do
    REPO_URLS=( ${REPO_URLS} \
                  $(echo ${res} | \
                       jq -r ".values[].links.clone[] | select(.name==\"${URL_SCHEME}\") | .href") )
  done

  for n in ${REPO_URLS}
  do
    if [[ ${n} =~ ${REPO_PATTERN} ]]
    then
      print -- ${n}
    fi
  done
}

check_health

if [[ -f ~/.bb.conf ]]
then
  . ~/.bb.conf
fi

while getopts ":n:o:s:uh" opt
do
  case $opt in
    h)
      print_usage
      exit 0
      ;;
    n)
      REPO_PATTERN=${OPTARG}
      ;;
    o)
      REPO_OWNER=${OPTARG}
      ;;
    s)
      URL_SCHEME=${OPTARG}
      ;;
    u)
      ATTRIBUTE=url
      ;;
    \?)
      >&2 print -- Invalid option -${OPTARG}.
      exit 1
      ;;
    :)
      >&2 print -- Missing argument to -${OPTARG}.
      exit 1
      ;;
  esac
done

shift $((OPTIND-1))

check_credentials
check_repository_vars

: ${REPO_PATTERN=.*}
: ${URL_SCHEME=https}
: ${ATTRIBUTE=name}

CURL=(curl -s -f --user ${BITBUCKET_USER}:${BITBUCKET_PASS})
CURL_HEAD=(${CURL} -I)
GETREPO=https://bitbucket.org/api/2.0/repositories/${REPO_OWNER}

typeset -a REPOSITORIES
typeset -a REPO_NAMES
typeset -a REPO_URLS
typeset -a PAGES

NEXT_PAGE=${GETREPO}

while [[ ! -z ${NEXT_PAGE} ]]
do
  RESPONSE=$(${CURL} ${NEXT_PAGE}) || {
    >&2 print -- The server returned an error.
    exit 2
  }

  PAGES=(${RESPONSE} ${PAGES})
  NEXT_PAGE=$(echo ${RESPONSE} | jq -r '.next')
  [[ ${NEXT_PAGE} == "null" ]] && NEXT_PAGE=""
done

case ${ATTRIBUTE} in
  name)
    print_names
    ;;
  url)
    print_urls
    ;;
  *)
    >&2 print -- Unexpected state.
    exit 3
    ;;
esac
