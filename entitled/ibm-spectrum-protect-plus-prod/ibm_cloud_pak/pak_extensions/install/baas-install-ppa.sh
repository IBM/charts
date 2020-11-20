#!/bin/bash

if ! ./baas-prereqs-checker.sh
then
  exit
fi

./baas-docker-login.sh
./baas-cleanup.sh
./baas-prereqs-airgap-ppa.sh
./baas-prereqs-create-baas-namespace.sh
./baas-prereqs-create-baas-registry-secret.sh
./baas-prereqs-create-baas-secret.sh
./baas-instcmd.sh
