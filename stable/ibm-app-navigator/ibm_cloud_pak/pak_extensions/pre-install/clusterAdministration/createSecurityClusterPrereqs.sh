#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2019. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
#
# You need to run this script once prior to installing the chart.
#

# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl apply -f ibm-app-navigator-psp.yaml
kubectl apply -f ibm-app-navigator-psp-cr.yaml
