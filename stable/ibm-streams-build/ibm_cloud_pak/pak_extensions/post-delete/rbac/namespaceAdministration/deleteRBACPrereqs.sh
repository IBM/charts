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
#     ./deleteServiceAccountRBACPrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteServiceAccountRBACPrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Delete the role binding for all service accounts in the current namespace  
kubectl delete serviceaccount ibm-streams-build-sa -n $namespace
kubectl delete serviceaccount ibm-streams-builder-sa -n $namespace
kubectl delete role ibm-streams-build-role -n $namespace
kubectl delete rolebinding ibm-streams-build-rb -n $namespace
