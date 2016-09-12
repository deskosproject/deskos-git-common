#!/bin/bash
#
# Script to parse the non-text sources metadata file
# and download the required files from the lookaside
# cache.
#
# Might want to drop this in ~/bin/ and chmod u+x it.
#
# License: GPLv3
# Ricardo Arguello <rarguello@deskosproject.org>

# DeskOS sources
SURL="https://dl.deskosproject.org/sources"

# Check metadata file and extract package name
shopt -s nullglob
set -- .*.metadata

if (( $# == 0 ))
then
  echo 'Missing metadata. Please run from inside a sources git repo' >&2
  exit 1
elif (( $# > 1 ))
then
  echo "Warning: multiple metadata files found. Using $1"
fi

meta=$1
pn=${meta%.metadata}
pn=${pn#.}

if [ ! -d .git ] || [ ! -d SPECS ]; then
  echo 'You need to run this from inside a sources git repo' >&2
  exit 1
fi

mkdir -p SOURCES

while read -r fsha fname ; do
  if [ ".${fsha}" = ".e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855" ]; then
    # zero byte file
    touch ${fname}
  else
    if [ ! -e "${fname}" ]; then
      # Remove SOURCES from filename
      realfname=${fname#SOURCES}
      # Download the file
      curl --silent -f "${SURL}/${pn}/${realfname}" -o "${fname}"
    else
      echo "${fname} exists, skipping"
    fi

    downsum=$(sha256sum ${fname} | awk '{print $1}')
    if [ "${fsha}" != "${downsum}" ]; then
      echo "Failure: ${fname} hash does not match hash from the .metadata file" >&2
      exit 1;
    fi
  fi
done < "${meta}"
