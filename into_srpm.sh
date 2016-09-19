#!/bin/bash -u
#
# Turn a DeskOS git repo into a .src.rpm file.
# Might want to drop this in ~/bin/ and chmod u+x it.
#
# License: GPLv3
# Ricardo Arguello <rarguello@deskosproject.org>

if [[ ! -d .git ]] || [[ ! -d SPECS ]]; then
  echo 'You need to run this from inside a sources git repo' >&2
  exit 1
fi

which get_sources.sh >/dev/null 2>&1
if [[ $? -ne 0 ]]; then
  echo 'You need get_sources.sh from deskos-git-common in PATH' >&2
  exit 1
fi

# Download sources from dl.deskosproject.org
get_sources.sh

SPECFILE=$(cd SPECS; ls *.spec)

# Build SRPM
rpmbuild --define "%_topdir `pwd`" -bs --nodeps --define "%dist .el7.deskos" --define "%rhel 7" --define "%centos 7" --define "%fedora 0" SPECS/${SPECFILE}

if [[ $? -ne 0 ]]; then
  echo "$0 failed to recreate SRPM"
  exit 1
fi
