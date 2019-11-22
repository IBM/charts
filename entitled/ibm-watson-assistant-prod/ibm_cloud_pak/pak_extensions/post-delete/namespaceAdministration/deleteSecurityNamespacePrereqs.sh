#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################


if [ "$#" -lt 1 ]; then
  echo "Usage: $0 RELEASE_NAMESPACE"
  exit 1
fi

namespace=$1


kubectl delete rolebinding watson-assistant-chart-role-binding-for-namespace-${namespace} -n ${namespace}
