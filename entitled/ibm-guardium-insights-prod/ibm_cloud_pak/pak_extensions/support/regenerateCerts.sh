#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################

# /*******************************************************************************
#  * NAME: regenerateCerts.sh
#  * DESCRIPTION: Script to delete all certificate secrets and have them re-generated
#  *******************************************************************************/
set -e

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 namespace"
    exit 1
fi

export NAMESPACE=$1

echo "Begin deleting all TLS secrets"
oc delete secret `oc get certificates --no-headers=true -n $NAMESPACE | awk '{print $3}'` -n $NAMESPACE 1>/dev/null
echo "Deleted all TLS secrets"

# Wait for certificates to be refreshed
certRefresh=1;
# Catch to ensure that all certificates have been refreshed
while [ $certRefresh -ne 0 ]; do
  output=`oc get certificates --no-headers=true -n $NAMESPACE | awk '{print $2}'` ;
  certRefresh=`echo -n $output | grep False | wc -l`;
  echo "Waiting for all certificates to be refreshed";
  sleep 15;
done

echo "All certificates have been updated with new TLS certificates"