#!/bin/bash
#
# You need to run this script once prior to installing the chart.
#

# Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
kubectl apply -f ibm-voice-gateway-psp.yaml
kubectl apply -f ibm-voice-gateway-cr.yaml
