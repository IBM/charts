#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script for each namespace.
#
# Example:
#     ./deleteSecretGenerationJobs.sh
#

kubectl delete job tls-secret-generator
kubectl delete job tokens-secret-generator
kubectl delete job rabbitmq-secret-generator