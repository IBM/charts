#!/bin/bash
# begin_generated_IBM_copyright_prolog                             
#                                                                  
# This is an automatically generated copyright prolog.             
# After initializing,  DO NOT MODIFY OR MOVE                       
# **************************************************************** 
# Licensed Materials - Property of IBM                             
# 5724-Y95                                                         
# (C) Copyright IBM Corp.  2018, 2019    All Rights Reserved.      
# US Government Users Restricted Rights - Use, duplication or      
# disclosure restricted by GSA ADP Schedule Contract with          
# IBM Corp.                                                        
#                                                                  
# end_generated_IBM_copyright_prolog                               
#
###############################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createServiceAccountRBACPrereqs.sh myNamespace pullsecret
#

if [ "$#" -lt 1 ]; then
	echo "Usage: createServiceAccountRBACPrereqs.sh NAMESPACE PULLSECRET"
  exit 1
fi

namespace=$1
pullsecret=$2
# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-build-sa.yaml > $namespace-ibm-streams-build-sa.yaml
sed -i 's/{{ PULLSECRET }}/'$pullsecret'/g' $namespace-ibm-streams-build-sa.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-builder-sa.yaml > $namespace-ibm-streams-builder-sa.yaml
sed -i 's/{{ PULLSECRET }}/'$pullsecret'/g' $namespace-ibm-streams-builder-sa.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-build-role.yaml > $namespace-ibm-streams-build-role.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-build-rb.yaml > $namespace-ibm-streams-build-rb.yaml

# Create the role binding for all service accounts in the current namespace  
kubectl create -f $namespace-ibm-streams-build-sa.yaml -n $namespace 
kubectl create -f $namespace-ibm-streams-builder-sa.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-build-role.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-build-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-streams-build-sa.yaml
rm $namespace-ibm-streams-builder-sa.yaml
rm $namespace-ibm-streams-build-role.yaml
rm $namespace-ibm-streams-build-rb.yaml
