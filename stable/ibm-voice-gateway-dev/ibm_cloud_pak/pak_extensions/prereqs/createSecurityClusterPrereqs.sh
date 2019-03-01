#!/bin/bash

###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018, 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure 
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation
###############################################################################
#
# You need to run this script once prior to installing the chart.
#

# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl apply -f ibm-voice-gateway-psp.yaml
kubectl apply -f ibm-voice-gateway-cr.yaml
