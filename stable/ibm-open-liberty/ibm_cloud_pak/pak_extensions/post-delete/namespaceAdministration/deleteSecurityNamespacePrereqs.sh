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
#     ./deleteSecurityNamespacePrereqs.sh myNamespace
#

if [ "$#" -lt 1 ]; then
	echo "Usage: deleteSecurityNamespacePrereqs.sh NAMESPACE"
  exit 1
fi

namespace=$1

# Replace the NAMESPACE tag with the namespace specified in a temporary yaml file.
sed 's/{{ NAMESPACE }}/'$namespace'/g' ../../pre-install/namespaceAdministration/ibm-open-liberty-rb.yaml > ../../pre-install/namespaceAdministration/$namespace-ibm-websphere-liberty-rb.yaml

# Delete the role binding for all service accounts in the current namespace
kubectl delete -f ../../pre-install/namespaceAdministration/$namespace-ibm-open-liberty-rb.yaml -n $namespace

# Clean up - delete the temporary yaml file.
rm ../../pre-install/namespaceAdministration/$namespace-ibm-open-liberty-rb.yaml
