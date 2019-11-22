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
#
# This script applies a taint to a node to reserve the node for use by the MessageSight server.
# It also applies the MessageSight server label to the specified node as an indication to helm to
# target the tainted node for server install.
#
# The script requires one argument; the name of the node.

if [ "$#" -lt 1 ]; then
    echo "Usage: applyMessageSightServerTaint.sh NODE_NAME"
    exit 1
fi

nodename=$1

kubectl taint nodes $nodename dedicated=messagesight:NoSchedule
kubectl label nodes $nodename messagesight=server
