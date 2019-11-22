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
#     ./createServiceAccountRBACPrereqs.sh myNamespace mypullsecret
#

if [ "$#" -lt 1 ]; then
	echo "Usage: createServiceAccountRBACPrereqs.sh NAMESPACE PULLSECRET RELEASENAME"
  exit 1
fi

namespace=$1
pullsecret=$2
releasename=$3

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-instance-sa.yaml > $namespace-ibm-streams-instance-sa.yaml
sed -i 's/{{ PULLSECRET }}/'$pullsecret'/g' $namespace-ibm-streams-instance-sa.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-instance-role.yaml > $namespace-ibm-streams-instance-role.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-instance-rb.yaml > $namespace-ibm-streams-instance-rb.yaml

sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-app-sa.yaml > $namespace-ibm-streams-app-sa.yaml
sed -i 's/{{ PULLSECRET }}/'$pullsecret'/g' $namespace-ibm-streams-app-sa.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-app-role.yaml > $namespace-ibm-streams-app-role.yaml
sed -i 's/{{ RELEASENAME }}/'$releasename'/g' $namespace-ibm-streams-app-role.yaml
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-streams-app-rb.yaml > $namespace-ibm-streams-app-rb.yaml

# Create the role binding for all service accounts in the current namespace  
kubectl create -f $namespace-ibm-streams-instance-sa.yaml -n $namespace 
kubectl create -f $namespace-ibm-streams-instance-role.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-instance-rb.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-app-sa.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-app-role.yaml -n $namespace
kubectl create -f $namespace-ibm-streams-app-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-streams-instance-sa.yaml
rm $namespace-ibm-streams-instance-role.yaml
rm $namespace-ibm-streams-instance-rb.yaml
rm $namespace-ibm-streams-app-sa.yaml
rm $namespace-ibm-streams-app-role.yaml
rm $namespace-ibm-streams-app-rb.yaml
