#!/bin/bash
#
#################################################################
# (C) Copyright 2019-2020 Syncsort Incorporated. All rights reserved.
#################################################################
#
# You need to run this once per cluster
#
# Example:
#     ./deleteSecurityClusterPrereqs.sh
#

. ../../common/kubhelper.sh


isApplied="false"
if supports_scc; then
  echo "Removing the SCC and ClusterRole..."
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-b2bi-cr-scc.yaml
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-b2bi-scc.yaml
  isApplied="true"
fi

if supports_psp; then
    if [ "$isApplied" == "false" ]; then
    	echo "Removing the PSP and ClusterRole..."
    	kubectl delete -f ../../pre-install/clusterAdministration/ibm-b2bi-cr.yaml
    	kubectl delete -f ../../pre-install/clusterAdministration/ibm-b2bi-psp.yaml
    fi
fi
