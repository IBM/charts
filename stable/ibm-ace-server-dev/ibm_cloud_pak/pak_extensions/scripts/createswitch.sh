#!/bin/bash -ex

# This script can be used to update an Integration Server deployed on OCP
# to run as a switch. Before running this script you must:
# * Be logged into the OCP cluster
# * Have the ace profile loaded in the current shell
# * Have created an integration server using a command such as:
#    helm install --name <ReleaseName> ibm-ace-server-dev --tls --set license=accept \
#       --set integrationServer.configurationSecret=<IntegrationSecret> --set aceonly.replicaCount=1 \
#       --set service.switchAgentPPort=9011
#

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    echo "Usage:"
    echo "   ./createswitch.sh <releaseName> <integrationSecret> <namespace>"
fi

RELEASE=$1
SECRET=$2
NAMESPACE=$3

SWITCH_HOSTNAME=$(kubectl get route $RELEASE-switch -n $NAMESPACE -o jsonpath="{.status.ingress[0].host}")
mkdir /tmp/switch
iibcreateswitchcfg -output /tmp/switch/ -hostname $SWITCH_HOSTNAME
kubectl create secret generic $SECRET --from-file=switch=/tmp/switch/switch.json -n $NAMESPACE --dry-run -o yaml | kubectl apply -f -
kubectl patch deployment $RELEASE-ibm-ace-server-dev -n $NAMESPACE -p "{\"spec\":{\"template\":{\"metadata\":{\"labels\":{\"date\":\"`date +'%s'`\"}}}}}"

# Patch the agentx.json file to work with OCP Routes
sed -i -e 's/:9011//g' /tmp/switch/agentx.json