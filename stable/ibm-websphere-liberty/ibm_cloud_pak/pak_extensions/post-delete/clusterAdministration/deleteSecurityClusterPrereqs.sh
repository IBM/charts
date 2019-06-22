#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
#
# This script can be run after all releases are deleted from the cluster.
#

. ../../common/kubhelper.sh

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

if supports_scc; then
  echo "Removing the SCC..."
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-liberty-scc.yaml
fi

if supports_psp; then
    echo "Removing the PSP and ClusterRole..."
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-liberty-psp.yaml
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-websphere-liberty-cr.yaml
fi