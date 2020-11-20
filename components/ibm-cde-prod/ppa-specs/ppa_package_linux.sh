#!/usr/bin/env bash

echo Creating offline package...
set -x
specname="ibm-dde-`uname -m`.yaml"
packagename="ibm-dde-1.13.20-`uname -m`.tgz"
modulename="ibm-dde-1.13.20-`uname -m`.tar"

offline-packager export -s $specname -o $packagename -v

rm $modulename
rm -fr ibm-cde-prod
mkdir ibm-cde-prod
cp ../icp4d-metadata.yaml ibm-cde-prod
cp ../patch.sh ibm-cde-prod
tar -zxvf $packagename -C ibm-cde-prod
tar -cvf $modulename ibm-cde-prod
rm -fr ibm-cde-prod
