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
# This script is only needed if the default PSP for your cluster is more restrictive than
# ibm-anyuid-hostaccess-psp.
#
# You only need to run this script one time per cluster.  
#
# Create custom MessageSight PSP and ClusterRole (Requires cluster administrator access)
kubectl create -f messagesight-cr-psp.yaml
