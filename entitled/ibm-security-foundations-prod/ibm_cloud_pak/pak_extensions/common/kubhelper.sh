#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# Source this file
# . kubhelper.sh



# Test the target Kubernetes cluster supports the specified resource name and API version.
# Parameters:  
#  1:  Kubernetes resource name
#  2:  Kubernetes API version
# Exit code:  
#  0:  Resource and Version exist
#  1:  Resource exists, but not the version.
#  2:  Resource and version do not exist.
resource_version_exists() {
    if [ -z "$1" ]; then echo "resource_version_exists() missing arg 1: resource"; fi
    if [ -z "$2" ]; then echo "resource_version_exists() missing arg 2: apiversion"; fi

    resource=$1
    apiversion=$2
    if kubectl api-resources -o name | grep "$resource" &> /dev/null; then
        if kubectl api-versions |  grep "$apiversion" &> /dev/null; then
          return 0;
        else
          return 1;
        fi
    fi
    return 2;
}

supports_scc() {
  resource_version_exists securitycontextconstraints.security.openshift.io security.openshift.io/v1
  return $?
}

supports_psp() {
  resource_version_exists podsecuritypolicies.extensions extensions/v1beta1
  return $?
}