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
# You need to run this script once prior to installing the chart.
#
# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl apply -f ibm-powerai-psp.yaml
kubectl apply -f ibm-powerai-cr.yaml