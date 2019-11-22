#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################


if [ "$#" -lt 1 ]; then
  echo "Usage: $0 RELEASE_NAMESPACE"
  exit 1
fi

namespace=$1

script_dir=$(dirname "$0")

# Creates the Role Binding
cat $script_dir/ibm-watson-assistant-prod-rolebinding.tpl | sed "s/{{ .Release.Namespace }}/${namespace}/g" >ibm-watson-assistant-prod-rolebinding.yaml
kubectl apply -f ibm-watson-assistant-prod-rolebinding.yaml

# Clean up - delete the temporary yaml file.
rm ibm-watson-assistant-prod-rolebinding.yaml
