#!/usr/bin/env bash

echo Creating offline package...
/c/dev/tools/win-offline-packager.exe export export -s ibm-dde.yaml -o ibm-dde-0.0.16.tar.gz -v
