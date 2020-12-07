#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018, 2019.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# You need to run this script once prior to installing the chart.
#

. ../../common/kubhelper.sh
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

if supports_psp; then 
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f $parent_path/ibm-redis-psp.yaml
  kubectl apply -f $parent_path/ibm-redis-cr.yaml
fi
