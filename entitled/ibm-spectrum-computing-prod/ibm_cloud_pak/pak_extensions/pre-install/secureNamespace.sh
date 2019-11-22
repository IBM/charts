#!/bin/bash
#
###############################################################################
# Licensed Materials - Property of IBM.
# Copyright IBM Corporation 2018. All Rights Reserved.
# U.S. Government Users Restricted Rights - Use, duplication or disclosure
# restricted by GSA ADP Schedule Contract with IBM Corp.
#
# Contributors:
#  IBM Corporation - initial API and implementation
###############################################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./secureNamespace.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: secureNamespace.sh [-d|-l] NAMESPACE"
  exit 1
fi

namespace=$1
ACTION=create
if [ $namespace = "-d" ]; then
    ACTION=delete
    if [ "$2" = "" ]; then
        echo "Usage: secureNamespace.sh [-d] NAMESPACE"
        exit 2
    fi
    namespace=$2
fi
if [ $namespace = "-l" ]; then
    # Dump what we have
    if [ "$2" = "" ]; then
        echo "Usage: secureNamespace.sh [-d] NAMESPACE"
        exit 2
    fi
    namespace=$2
    echo "-----  Roles ---------------------"
    kubectl get roles -n $namespace 
    echo "-----  Role ibm-spectrum-computing-role-$namespace contents"
    kubectl describe role ibm-spectrum-computing-role-$namespace -n $namespace
    echo "-----  RoleBindings --------------"
    kubectl get rolebindings -n $namespace
    echo "-----  RoleBindings ibm-spectrum-computing-rolebinding contents"
    kubectl describe rolebinding ibm-spectrum-computing-rolebinding contents -n $namespace
    echo "-----  ClusterRoles ibm-spectrum-computing-clusterrole contents"
    kubectl describe clusterrole ibm-spectrum-computing-clusterrole
    
    exit 0
fi

# Check for PSP and make if needed
HAVEPSP=$(kubectl get psp |grep -c ibm-spectrum-computing-psp)
if [ ${HAVEPSP} -eq 0 ]; then
    kubectl create -f ibm-spectrum-computing-psp.yaml
else
    echo "PodSecurityPolicy ibm-spectrum-computing-psp already exists... ignoring"
fi

# Check for ClusterRole and create if needed
HAVECR=$(kubectl get clusterrole |grep -c ibm-spectrum-computing-clusterrole)
if [ ${HAVECR} -eq 0 ]; then
    kubectl create -f ibm-spectrum-computing-cr.yaml
else
    echo "ClusterRole ibm-spectrum-computing-clusterrole already exists... ignoring"
fi

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-spectrum-computing-rb.yaml > $namespace-ibm-spectrum-computing-rb.yaml

# Create the role binding for all service accounts in the current namespace
kubectl ${ACTION} -f $namespace-ibm-spectrum-computing-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm $namespace-ibm-spectrum-computing-rb.yaml

