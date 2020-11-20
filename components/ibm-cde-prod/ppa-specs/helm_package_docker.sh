#!/usr/bin/env bash

echo Creating Helm package for DDE
rm -fr charts
mkdir charts
helm package --destination charts ../.
