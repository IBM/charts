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
# This script can be run after all releases are deleted from the cluster.
#

. ../../common/kubhelper.sh

# Delete the PodSecurityPolicy and ClusterRole for all releases of this chart.

if supports_scc; then
  echo "Removing the SCC..."
  kubectl delete -f ../../pre-install/clusterAdministration/ibm-open-liberty-spring-scc.yaml
fi

if supports_psp; then
    echo "Removing the PSP and ClusterRole..."
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-open-liberty-spring-psp.yaml
    kubectl delete -f ../../pre-install/clusterAdministration/ibm-open-liberty-spring-cr.yaml
fi