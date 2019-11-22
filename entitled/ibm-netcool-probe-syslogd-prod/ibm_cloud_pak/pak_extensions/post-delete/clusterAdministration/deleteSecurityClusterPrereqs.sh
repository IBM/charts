#!/usr/bin/env bash
#
########################################################################
#
# Licensed Materials - Property of IBM
#
# 5725-Q09
#
# (C) Copyright IBM Corp. 2018,2019. All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Netcool/OMNIbus Probe
#
########################################################################
#
# This script can be run after all releases are deleted from the cluster.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
echo "Deleting Pod Security Policy"
kubectl delete -f $scriptDir/../../pre-install/clusterAdministration/ibm-netcool-probe-syslogd-prod-psp.yaml

echo "Deleting ClusterRole"
kubectl delete -f $scriptDir/../../pre-install/clusterAdministration/ibm-netcool-probe-syslogd-prod-cr.yaml