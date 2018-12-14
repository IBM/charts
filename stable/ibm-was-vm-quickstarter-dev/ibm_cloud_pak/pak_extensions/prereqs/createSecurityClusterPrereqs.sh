#!/bin/bash -e
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
# You need to run this script once prior to installing the chart.
#

# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
cd $(dirname $0)

kubectl apply -f ibm-was-vm-quickstarter-psp.yaml
kubectl apply -f ibm-was-vm-quickstarter-cr.yaml
