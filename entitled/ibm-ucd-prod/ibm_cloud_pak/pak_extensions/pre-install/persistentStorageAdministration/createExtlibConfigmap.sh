#!/bin/bash

#
# Create a configMap to copy JDBC driver file(s) from a accessible webserver
# into the extlib Persistent Volume. You will need to modify the configMap
# template file (ibm-ucd-prod-extlib-configMap.yaml) to reference your
# webserver and the JDBC driver file(s) you are copying.
#
# You need to run this script once prior to installing the chart.
#

[[ $(dirname $0 | cut -c1) = '/' ]] && scriptDir=$(dirname $0)/ || scriptDir=$(pwd)/$(dirname $0)/

# Create the configMap used to copy the JDBC driver file(s)
echo "Creating configMap from $scriptDir/ibm-ucd-prod-extlib-configMap.yaml template file"
kubectl apply -f $scriptDir/ibm-ucd-prod-extlib-configMap.yaml

