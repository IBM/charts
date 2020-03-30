#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

if supports_scc; then 
  # Fix known issue with icp-scc
  kubectl patch scc icp-scc --type='json' -p='[{"op": "remove", "path": "/groups"}]'
  kubectl patch scc icp-scc --type='json' -p='[{"op": "add", "path": "/users", "value": ["system:serviceaccount:kube-system:default","system:serviceaccount:istio-system:default", "system:serviceaccount:cert-manager:default"] }]'

  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ibm-icp4i-prod-scc.yaml --validate=false
  oc adm policy add-scc-to-group ibm-icp4i-prod-scc system:authenticated
fi
