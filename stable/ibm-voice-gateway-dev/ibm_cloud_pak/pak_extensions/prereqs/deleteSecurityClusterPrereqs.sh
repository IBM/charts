#!/bin/bash
#
# This script can be run after all releases are deleted from the cluster.
#

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl delete -f ibm-voice-gateway-psp.yaml
kubectl delete -f ibm-voice-gateway-cr.yaml
