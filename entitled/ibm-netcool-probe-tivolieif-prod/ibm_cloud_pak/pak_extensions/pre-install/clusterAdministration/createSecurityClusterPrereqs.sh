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
# You need to run this script once prior to installing the chart.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
pspTemplate=$scriptDir/ibm-netcool-probe-tivolieif-prod-psp.yaml
echo "Creating Pod Security Policy from $pspTemplate template file"
kubectl apply -f $pspTemplate

crTemplate=$scriptDir/ibm-netcool-probe-tivolieif-prod-cr.yaml
echo "Creating Cluster Role from $crTemplate template file"
kubectl apply -f $crTemplate