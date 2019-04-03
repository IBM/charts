#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018,2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# This script can be run after all releases are deleted from the cluster.
#

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl delete -f ibm-powerai-psp.yaml
kubectl delete -f ibm-powerai-cr.yaml