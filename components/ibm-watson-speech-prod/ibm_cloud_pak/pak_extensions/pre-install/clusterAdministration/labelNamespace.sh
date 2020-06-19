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
  echo "Usage: $0 ICP4D_NAMESPACE (Where ICP4D is installed)"
  exit 1
fi

namespace=$1

# Label the namespace so the NetworkPolicy can allow nginx pods from this namespace
output=$(kubectl label --overwrite namespace $namespace ns=$namespace 2>&1)

if [ $? -eq 0 ]; then
  echo "$output"
  exit 0
fi

echo $output | grep 'already has a value' 2>&1 >/dev/null

if [ $? -eq 0 ]; then
  echo "namespace: $namespace is already labeled, success"
  exit 0
else
  echo "$output"
  exit 1
fi