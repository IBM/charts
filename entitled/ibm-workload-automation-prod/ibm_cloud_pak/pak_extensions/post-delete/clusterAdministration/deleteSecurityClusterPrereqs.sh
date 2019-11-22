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
# You need to run this once per cluster
#
# Example:
#     ./deleteSecurityClusterPrereqs.sh
#

# Delete the ClusterRole and PodSecurityPolicy
kubectl delete -f ../../pre-install/clusterAdministration/wa-cr.yaml
kubectl delete -f ../../pre-install/clusterAdministration/wa-psp.yaml