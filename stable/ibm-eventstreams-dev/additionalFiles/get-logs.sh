#!/bin/bash -x
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corporation 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.


# This script collects the log files from available pods and tars them up.
# It uses the component label names instead of the pod names as the pod names could be truncated.
#
# Pre-conditions
# 1) kubectl must be installed
# 2) User must be logged into host e.g. cloudctl login -a https:<hostname>:8443 --skip-ssl-validation -u admin -p admin
#
# Usage
# . get-logs.sh
#  optional arguments:
#     -n|-ns|-namespace=#, where # is the required namespace. If not entered it retrieves logs from the default namespace as requested in the cloudctl login
#     -r|-rel|-release=#, where # is the required release name. If not entered it returns logs for all releases.
#  example:
#     . get-logs.sh -n=es -r=testrelease

DATE=`date +%d-%m-%y`

unset NAMESPACE
unset RELEASE

access_controller_component_name="security"
elastic_component_name="elastic"
indexmgr_component_name="indexmgr"
kafka_component_name="kafka"
proxy_component_name="proxy"
rest_component_name="rest"
ui_component_name="ui"
zookeeper_component_name="zookeeper"

# Handle input arguments
while [ "$#" -gt 0 ]; do
    arg=$1
    case $1 in
        # convert "-opt=the value" to -opt "the value".
        -*'='*) shift; set - "${arg%%=*}" "${arg#*=}" "$@"; continue;;
        -n|-ns|-namespace) shift; NAMESPACE=$1;;
        -r|-rel|-release) shift; RELEASE=$1;;
        *) break;;
    esac
    shift
done

command="kubectl get pods __namespace__ -l component=__component____release__ --no-headers -o custom-columns=":metadata.name""

# Substitute in namespace if given
if [ -n "${NAMESPACE}" ]; then
    command="${command//__namespace__/-n ${NAMESPACE}}"
else
    command="${command//__namespace__/}"
fi

# Substitute in release if given
if [ -n "${RELEASE}" ]; then
    command="${command//__release__/,release=${RELEASE}}"
else
    command="${command//__release__/}"
fi


logdir="tmpLogs"
rm -rf $logdir
mkdir -p $logdir

# Extract host information
echo -n -e "Extracting host information"
kubectl get namespaces > $logdir/namespaces.log
kubectl get nodes > $logdir/nodes.log
kubectl get deployment > $logdir/deployment.log
kubectl get pods > $logdir/pods.log
kubectl -n kube-system get pods > $logdir/kube-system.log
kubectl get pods -o yaml > $logdir/yaml.log
echo -e "\033[0;32m [DONE]\033[0m"

# ACCESS-CONTROLLER pods
accesscontrollercommand="${command//__component__/${access_controller_component_name}}"
pods=$(eval $accesscontrollercommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod access-controller > $logdir/$pod/accesscontroller.log
    kubectl logs $pod redis > $logdir/$pod/kubectl-redis.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# ELASTIC pods
elasticcommand="${command//__component__/${elastic_component_name}}"
pods=$(eval $elasticcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod > $logdir/$pod/elastic.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# INDEX-MANAGER pod
indexmgrcommand="${command//__component__/${indexmgr_component_name}}"
pods=$(eval $indexmgrcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod > $logdir/$pod/indexmgr.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# KAFKA pods
kafkacommand="${command//__component__/${kafka_component_name}}"
pods=$(eval $kafkacommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod kafka > $logdir/$pod/kafka.log
    kubectl logs $pod metrics-reporter > $logdir/$pod/metrics-reporter.log
    kubectl logs $pod metrics-proxy > $logdir/$pod/metrics-proxy.log
    kubectl logs $pod healthcheck > $logdir/$pod/healthcheck.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# PROXY pods
kafkacommand="${command//__component__/${proxy_component_name}}"
pods=$(eval $kafkacommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod > $logdir/$pod/proxy.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST pod
restcommand="${command//__component__/${rest_component_name}}"
pods=$(eval $restcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod rest > $logdir/$pod/rest.log
    kubectl logs $pod codegen > $logdir/$pod/codegen.log
    kubectl logs $pod proxy > $logdir/$pod/proxy.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# UI pod
uicommand="${command//__component__/${ui_component_name}}"
pods=$(eval $uicommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod ui > $logdir/$pod/ui.log
    kubectl logs $pod redis > $logdir/$pod/redis.log
    kubectl logs $pod proxy > $logdir/$pod/proxy.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# ZOOKEEPER pods
zkcommand="${command//__component__/${zookeeper_component_name}}"
pods=$(eval $zkcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    kubectl logs $pod > $logdir/$pod/zookeeper.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# Tar the results
tar czf logs-$DATE.tar.gz $logdir
rm -rf $logdir
echo "COMPLETE - Results are in logs-$DATE.tar.gz"
