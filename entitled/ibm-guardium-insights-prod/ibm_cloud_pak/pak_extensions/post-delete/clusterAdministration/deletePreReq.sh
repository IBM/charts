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
# You need to run this script once after uninstall of the chart.
#

. ../../common/kubhelper.sh

if supports_psp; then 
  # Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Deleting the PodSecurityPolicy..."
  kubectl delete -f ../../pre-install/dependenciesSetup/ibm-redis-psp.yaml
  kubectl delete -f ../../pre-install/dependenciesSetup/ibm-redis-cr.yaml
fi
