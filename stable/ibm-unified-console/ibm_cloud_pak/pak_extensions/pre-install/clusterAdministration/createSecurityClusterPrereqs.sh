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

[[ `dirname $0 | cut -c1` = '/' ]] && DIR=`dirname $0`/ || DIR=`pwd`/`dirname $0`

source ${DIR}/../../common/kubhelper.sh


if supports_scc; then
  # Create the custom SCC for OpenShift
  echo "Creating SecurityContextConstraints..."
  cat ${DIR}/scc.yaml
  kubectl apply -f "${DIR}/scc.yaml" --validate=false
fi

if supports_psp; then
  # Create the PodSecurityPolicy and ClusterRole for all releases of this chart.
  echo "Creating the PodSecurityPolicy..."
  kubectl apply -f "${DIR}/psp.yaml"
  kubectl apply -f "${DIR}/cr.yaml"
fi