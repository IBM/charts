#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5737-E91 IBM Agile Lifecycle Manager
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
kubectl delete -f ibm-alm-prod-psp.yaml
kubectl delete -f ibm-alm-prod-cr.yaml
