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
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh

if supports_scc; then 
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  kubectl apply -f ibm-open-liberty-scc.yaml --validate=false
fi

if supports_psp; then 
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f ibm-open-liberty-psp.yaml
  kubectl apply -f ibm-open-liberty-cr.yaml
fi