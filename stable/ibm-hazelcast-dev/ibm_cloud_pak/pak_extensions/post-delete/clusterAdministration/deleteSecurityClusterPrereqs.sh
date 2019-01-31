#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
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
kubectl delete -f ../../pre-install/clusterAdministration/ibm-hazelcast-dev-cr.yaml
kubectl delete -f ../../pre-install/clusterAdministration/ibm-hazelcast-dev-psp.yaml
