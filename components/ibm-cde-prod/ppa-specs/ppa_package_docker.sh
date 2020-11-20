#!/usr/bin/env bash

echo Creating offline package...
set -x
version=$1
specname="ibm-dde-`uname -m`.yaml"
packagename="ibm-dde-$version-`uname -m`.tgz"
modulename="ibm-dde-$version-`uname -m`.tar"

offline-packager export -s $specname -o $packagename -v

rm $modulename
rm -fr daas
mkdir daas
cp ../icp4d-metadata.yaml daas
cp ../patch.sh daas
tar -zxvf $packagename -C daas
tar -cvf $modulename daas
rm -fr daas
