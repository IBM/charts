#!/bin/bash
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020. All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
################################################################# 

SELF_FILE=`basename $0`

if [[ $# -lt 1 ]]; then
    echo "Usage: $SELF_FILE [start/stop]"
    echo ""
    echo "- stop will write a .previousGuardiumInsightsReplicas file used for restarting the services"
    echo "- start will use the .previousGuardiumInsightsReplicas file created from stop"
    exit 1
fi

X=`oc get deployments -lproject=insights -oname`
if [ "X$1" == "Xstop" ]; then
    echo '' > .previousGuardiumInsightsReplicas
    for i in $X; do 
        Y=`oc get $i -ogo-template='{{ .spec.replicas }}'`; 
        if [[ "X$?" != "X0" ]]; then 
            Y=`oc get $i -ogo-template='{{ .spec.replicas }}'`;
            if [[ "X$?" != "X0" ]]; then 
                Y=`oc get $i -ogo-template='{{ .spec.replicas }}'`; 
                if [[ "X$?" != "X0" ]]; then 
                    echo "Failed to retrieve original replicas for $i from the existing deployment, nothing was scaled down"
                    echo "Please re-run this script"
                    exit 1
                fi
            fi
        fi
        I=`echo $i | sed -e 's#[-\./]#_#g'`; 
        echo $I=$Y >> .previousGuardiumInsightsReplicas;
    done
    oc scale `oc get deployments -lproject=insights -oname` --replicas=0
    echo Successfully Stopped Guardium Insights microservices
elif [ "X$1" == "Xstart" ]; then
    if [ ! -f .previousGuardiumInsightsReplicas ]; then
        echo "Error cannot find .previousGuardiumInsightsReplicas previously created by '$SELF_FILE stop' used to scale back up to the previous number"
        echo ""
        echo "Please run to get a list of Guardium Insights deployments:"
        echo "> oc get deployments -lproject=insights -oname"
        echo "for each entry, please scale Each deployment up manually by running:" 
        echo "> oc scale <output from previous command> --replicas=<replica_number>" 
        echo "where replica_number matches the value located in values-small/med/large.yaml depending on your deployment"
        exit 1
    fi
    source .previousGuardiumInsightsReplicas
    for i in $X; do 
        I=`echo $i | sed -e 's#[-\./]#_#g'`; 
        oc scale $i --replicas=${!I};
    done
    echo Successfully Started Guardium Insights microservices
fi