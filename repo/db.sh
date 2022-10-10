#!/bin/bash
#
# Script name: build-db.sh
# Description: Script for rebuilding the database for dtos-core-repo.
# GitLab: https://www.gitlab.com/dwt1/dtos-core-repo
# Contributors: Derek Taylor

# Set with the flags "-e", "-u","-o pipefail" cause the script to fail
# if certain things happen, which is a good thing.  Otherwise, we can
# get hidden bugs that are hard to discover.
set -euo pipefail

x86_pkgbuild=$(find packages/x86 -type f -name "*.pkg.tar.zst*")

for x in ${x86_pkgbuild}
do
    mv "${x}" x86_64/
    echo "Moving ${x}"
done


echo "###########################"
echo "Building the repo database."
echo "###########################"

## Arch: x86_64
cd x86_64
rm -f 46620-repo*

echo "###################################"
echo "Building for architecture 'x86_64'."
echo "###################################"

## repo-add
## -s: signs the packages
## -n: only add new packages not already in database
## -R: remove old package files when updating their entry
repo-add -s -n -R 46620-repo.db.tar.gz *.pkg.tar.zst

# Removing the symlinks because GitLab can't handle them.
rm 46620-repo.db
rm 46620-repo.db.sig
rm 46620-repo.files
rm 46620-repo.files.sig

# Renaming the tar.gz files without the extension.
mv 46620-repo.db.tar.gz 46620-repo.db
mv 46620-repo.db.tar.gz.sig 46620-repo-db.sig
mv 46620-repo.files.tar.gz 46620-repo.files
mv 46620-repo.files.tar.gz.sig 46620-repo.files.sig

echo "#######################################"
echo "Packages in the repo have been updated!"
echo "#######################################"

