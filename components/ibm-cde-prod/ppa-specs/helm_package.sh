#!/usr/bin/env bash

echo Creating Helm package for DDE
mkdir charts
/c/dev/tools/linux-amd64/helm package --destination charts ../.
