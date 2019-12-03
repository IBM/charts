#!/bin/bash
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2019  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#

# This script creates the Security Context Constraint (SCC) required to run Event Streams
# on Red Hat OpenShift. It is run BEFORE the first helm install.
#
# This script is only required for OpenShift releases.
#
# Usage:
#   ./scc.sh <namespace>
#
# Where:
#   namespace = the namespace previously set up for this release

namespace=$1

if [[ "$#" -ne 1 ]] || [[ -z ${namespace} ]]; then
    echo "Usage: ./scc.sh <namespace>"
    exit 1
fi

oc apply -f ibm-es-scc.yaml
oc adm policy add-scc-to-group ibm-es-scc system:serviceaccounts:$namespace
