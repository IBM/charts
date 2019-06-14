#!/bin/bash
#
###############################################################################
# Copyright (c) 2017 IBM Corp.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
###############################################################################
#
# You need to run this script for each namespace.
#
# This script takes one argument; the namespace where the chart will be installed.
#
# Example:
#     ./createSecurityNamespacePrereqs.sh myNamespace
#

. ../../common/kubhelper.sh


if [ "$#" -lt 1 ]; then
	echo "Usage: createSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

kubectl get namespace $namespace &> /dev/null
if [ $? -ne 0 ]; then
  echo "ERROR: Namespace $namespace does not exist."
  exit 1
fi

if supports_scc; then
  echo "Adding all namespace users to SCC..."
  if command -v oc >/dev/null 2>&1 ; then
    oc adm policy add-scc-to-group ibm-open-liberty-scc system:serviceaccounts:$namespace
  else
    echo "ERROR:  The OpenShift CLI is not available..." 
  fi
fi

if supports_psp; then
  # Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
  sed 's/{{ NAMESPACE }}/'$namespace'/g' ibm-open-liberty-rb.yaml > $namespace-ibm-open-liberty-rb.yaml

  echo "Adding a RoleBinding for all namespace users to the PSP..."
  # Create the role binding for all service accounts in the current namespace
  kubectl create -f $namespace-ibm-open-liberty-rb.yaml -n $namespace

  # Clean up - delete the temporary yaml file.
  rm $namespace-ibm-open-liberty-rb.yaml
fi;