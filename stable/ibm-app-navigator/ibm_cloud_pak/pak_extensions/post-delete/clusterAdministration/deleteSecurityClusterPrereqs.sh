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
# This script can be run after all releases are deleted from the cluster.
#

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl delete -f ibm-app-navigator-psp.yaml
kubectl delete -f ibm-app-navigator-psp-cr.yaml
