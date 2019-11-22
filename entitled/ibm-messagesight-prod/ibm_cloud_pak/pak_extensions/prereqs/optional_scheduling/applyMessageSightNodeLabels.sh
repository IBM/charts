#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# 5725-S17 IBM IoT MessageSight
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
# This script applies a label to a node so that helm install gives preference to that node for installing either 
# the MessageSight server or the MessageSight Web UI.
# If you use the 
# It requires two arguments; the name of the node and either server or webui.

if [ "$#" -lt 2 ]; then
    echo "Usage: applyMessageSightServerTaint.sh NODE_NAME server|webui"
    exit 1
fi
nodename=$1
compname=$2

if [[ "$compname" == "server" ]]; then
    kubectl label nodes $nodename messagesight=server
elif [[ "$compname" == "webui" ]]; then
    kubectl label nodes $nodename messagesight=webui
else
    echo "FAILED. No label applied because $compname is not a valid MessageSight component name.  You must specify server or webui."
    exit 1
fi

