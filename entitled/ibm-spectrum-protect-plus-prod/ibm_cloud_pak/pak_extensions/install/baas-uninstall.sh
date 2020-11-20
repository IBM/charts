#!/bin/bash

#==================================================================================================
echo "Perform a Helm 3 uninstall"
#==================================================================================================

echo "helm3 uninstall ibm-spectrum-protect-plus-prod --namespace baas"
helm3 uninstall ibm-spectrum-protect-plus-prod --namespace baas

./baas-cleanup.sh
./baas-docker-remove-images.sh

#==================================================================================================
echo "Complete"
#==================================================================================================