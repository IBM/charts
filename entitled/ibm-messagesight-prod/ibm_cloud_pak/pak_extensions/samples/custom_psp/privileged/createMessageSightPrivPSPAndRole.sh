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
# You only need to run this script one time per cluster. This script is needed only if you will be using
# persistent volumes that require you to run MessageSight as the root user.
#
# Create custom privileged MessageSight PSP and ClusterRole (Requires cluster administrator access)
kubectl create -f messagesight-priv-cr-psp.yaml