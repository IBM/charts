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
# Use this script to create a namespace and to create a rolebinding that associates the namespece with the ibm-anyuid-hostaccess-psp.
# This script requires cluster administrator access.
#
# Run this script for each namespace that you create for MessageSight installations that use the ibm-anyuid-hostaccess-psp.  This script
# creates a namespace and a role binding for the ibm-anyuid-hostaccess-psp.  
# 
# This script takes the namespace name as a single required argument.
#
# Examples:
#     ./createNamespaceAndRoleBinding.sh messagesight
#  Creates the namespace messagesight and associates it with the ibm-anyuid-hostaccess-psp.
#


if [ "$#" -lt 1 ]; then
    echo "Usage: createNamespaceAndRoleBinding.sh NAMESPACE"
    exit 1
fi

namespace=$1

# Create the namespace 
kubectl create namespace ${namespace}

# Create the RoleBinding that associates the default service account the new namespace with the ibm-anyuid-hostaccess-psp.
#
# 1. Create the input configuration file from a template.
#
sed 's/{{ namespace }}/'${namespace}'/g' default_rb_template.yaml > default_rb.yaml

# 2. Create the role binding for the default service account in the new namespace.
#
kubectl create -f default_rb.yaml -n ${namespace}

