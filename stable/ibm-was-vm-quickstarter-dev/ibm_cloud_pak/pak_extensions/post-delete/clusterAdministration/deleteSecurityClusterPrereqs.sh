#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# This script can be run after all releases are deleted from the cluster.
#

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
cd $(dirname $0)

kubectl delete -f ../../pre-install/clusterAdministration/ibm-was-vm-quickstarter-psp.yaml
kubectl delete -f ../../pre-install/clusterAdministration/ibm-was-vm-quickstarter-cr.yaml
