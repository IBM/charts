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
# Usage:
#     ./postCSUpgrade.sh
#

CS_NAMESPACE='ibm-common-services'

#===  FUNCTION  ================================================================
#   NAME: scaledownCS
#   DESCRIPTION:  scaledown CS 3.4
# ===============================================================================
scaledownCS() {
    
    echo "INFO: Preparing and Scaling CS 3.4 for the Upgrade"
    cs_replicas=$(kubectl get deploy --no-headers -n $CS_NAMESPACE |\
        grep -E "catalog-ui|system-healthcheck-service" | awk '{print $1}')
    for replica in ${cs_replicas[@]}; do
        echo "INFO: Scaling Deployment $replica: 0 Replicas"
        kubectl scale deploy "$replica" -n "$CS_NAMESPACE" --replicas=0
    done

}

# ============= MAIN ===============
scaledownCS
