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
# You only need to run this script one time per cluster.  The default ServiceAccounts for the MessageSight charts
# (messagesight-sa and messagesight-priv-sa that the createDefaultSvcAcctsAndRoleBindings.sh creates) depend on the 
# PSP and ClusterRole that are created in this script.
#
# Create default MessageSight PSP and ClusterRole (Requires cluster administrator access)
kubectl create -f messagesight-cr-psp.yaml

# Create default privileged MessageSight PSP and ClusterRole (Requires cluster administrator access)
kubectl create -f messagesight-priv-cr-psp.yaml