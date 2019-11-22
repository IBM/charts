#!/bin/bash -x
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corp. 2018, 2019  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#


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
collector_componenet_name="collector"
elastic_component_name="elastic"
indexmgr_component_name="indexmgr"
kafka_component_name="kafka"
proxy_component_name="proxy"
rest_component_name="rest"
rest_producer_component_name="rest-producer"
rest_proxy_component_name="rest-proxy"
replicator_component_name="replicator"
schema_registry_component_name="schemaregistry"
ui_component_name="ui"
zookeeper_component_name="zookeeper"
essential_component_name="essential"

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

command='kubectl get pods __namespace__ -l component=__component____release__ --no-headers -o custom-columns=":metadata.name"'
netpolcommand='kubectl get netpol __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'
servicecommand='kubectl get svc __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'
configmapcommand='kubectl get configmap __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'
secretcommand='kubectl get secrets __namespace__ __release__ --no-headers -o custom-columns=":metadata.name"'
nodecommand='kubectl get nodes --no-headers -o custom-columns=":metadata.name"'
icpconfigmapcommand='kubectl get configmap -n kube-public --no-headers -o custom-columns=":metadata.name"'
pvcommand='kubectl get pv --no-headers -o custom-columns=":metadata.name"'
pvccommand='kubectl get pvc --no-headers -o custom-columns=":metadata.name"'
kubesystemcommand='kubectl get pods -n kube-system --no-headers -o custom-columns=":metadata.name"'
certgencommand='kubectl get pods  -n kube-system -l component=essential --no-headers -o custom-columns=":metadata.name"'
oauthcommand='kubectl get pods -n kube-system -l component=ui --no-headers -o custom-columns=":metadata.name"'

# Substitute in namespace if given
if [ -n "${NAMESPACE}" ]; then
    command="${command//__namespace__/-n ${NAMESPACE}}"
    netpolcommand="${netpolcommand//__namespace__/-n ${NAMESPACE}}"
    servicecommand="${servicecommand//__namespace__/-n ${NAMESPACE}}"
    configmapcommand="${configmapcommand//__namespace__/-n ${NAMESPACE}}"
    secretcommand="${secretcommand//__namespace__/-n ${NAMESPACE}}"
else
    command="${command//__namespace__/}"
    netpolcommand="${netpolcommand//__namespace__/}"
    servicecommand="${servicecommand//__namespace__/}"
    configmapcommand="${configmapcommand//__namespace__/}"
    secretcommand="${secretcommand//__namespace__/}"
fi

# Substitute in release if given
if [ -n "${RELEASE}" ]; then
    command="${command//__release__/,release=${RELEASE}}"
    netpolcommand="${netpolcommand//__release__/-l release=${RELEASE}}"
    servicecommand="${servicecommand//__release__/-l release=${RELEASE}}"
    configmapcommand="${configmapcommand//__release__/-l release=${RELEASE}}"
    secretcommand="${secretcommand//__release__/-l release=${RELEASE}}"
else
    command="${command//__release__/}"
    netpolcommand="${netpolcommand//__release__/}"
    servicecommand="${servicecommand//__release__/}"
    configmapcommand="${configmapcommand//__release__/}"
    secretcommand="${secretcommand//__release__/}"
fi


logdir="tmpLogs"
netpollogdir="netpolLogs"
servicelogdir="serviceLogs"
tillerlogdir="tillerLogs"
nodelogdir="nodeLogs"
helmlogdir="helmLogs"
pvlogdir="pvLogs"
pvclogdir="pvcLogs"
kubednslogdir="kube-dnsLogs"
certificatedir="certificates"
certgenlogdir="certgenLogs"
oauthlogdir="oauthLogs"
rm -rf $logdir
mkdir -p $logdir
mkdir -p $logdir/$netpollogdir
mkdir -p $logdir/$servicelogdir
mkdir -p $logdir/$tillerlogdir
mkdir -p $logdir/$nodelogdir
mkdir -p $logdir/$helmlogdir
mkdir -p $logdir/$pvlogdir
mkdir -p $logdir/$pvclogdir
mkdir -p $logdir/$kubednslogdir
mkdir -p $logdir/$certificatedir
mkdir -p $logdir/$certgenlogdir
mkdir -p $logdir/$oauthlogdir


# Extract host information
echo -n -e "Extracting host information"
kubectl get namespaces > $logdir/namespaces.log
kubectl get nodes --show-labels -o wide > $logdir/nodes.log
kubectl get deployment > $logdir/deployment.log
kubectl get pods -o wide -L zone > $logdir/pods.log
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
    containers=($(${accesscontrollercommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# COLLECTOR pods
collectorcommand="${command//__component__/${collector_componenet_name}}"
pods=$(eval $collectorcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${collectorcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# ELASTIC pods
elasticcommand="${command//__component__/${elastic_component_name}}"
pods=$(eval $elasticcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${elasticcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# INDEX-MANAGER pod
indexmgrcommand="${command//__component__/${indexmgr_component_name}}"
pods=$(eval $indexmgrcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${indexmgrcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# KAFKA pods
kafkacommand="${command//__component__/${kafka_component_name}}"
pods=$(eval $kafkacommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${kafkacommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# PROXY pods
proxycommand="${command//__component__/${proxy_component_name}}"
pods=$(eval $proxycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${proxycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST pod
restcommand="${command//__component__/${rest_component_name}}"
pods=$(eval $restcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST PRODUCER pod
restproducercommand="${command//__component__/${rest_producer_component_name}}"
pods=$(eval $restproducercommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restproducercommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REST PROXY pod
restproxycommand="${command//__component__/${rest_proxy_component_name}}"
pods=$(eval $restproxycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${restproxycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# REPLICATOR pod
replicatorcommand="${command//__component__/${replicator_component_name}}"
pods=$(eval $replicatorcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${replicatorcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# SCHEMA REGISTRY pod
schemaregistrycommand="${command//__component__/${schema_registry_component_name}}"
pods=$(eval $schemaregistrycommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${schemaregistrycommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# UI pod
uicommand="${command//__component__/${ui_component_name}}"
pods=$(eval $uicommand)
for pod in $pods; do
    if ! [[ "$pod" =~ "ui-oauth2" ]];then 
        echo -n -e $pod
        mkdir -p $logdir/$pod
        kubectl describe pod $pod > $logdir/$pod/pod-describe.log
        containers=($(kubectl get po $pod -o jsonpath={.spec.containers[*].name}))
        for container in ${containers[@]}; do
            kubectl logs $pod -c $container > $logdir/$pod/$container.log
            kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
            if [ $(eval echo $?) == 1 ]; then
                rm $logdir/$pod/$container-previous.log
            fi
        done
        kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
        kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
        echo -e "\033[0;32m [DONE]\033[0m"
    else 
        echo "Ignoring pod $pod"
    fi
done

# ZOOKEEPER pods
zkcommand="${command//__component__/${zookeeper_component_name}}"
pods=$(eval $zkcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$pod
    kubectl describe pod $pod > $logdir/$pod/pod-describe.log
    containers=($(${zkcommand} -o jsonpath={.items[*].spec.containers[*].name}))
    for container in ${containers[@]}; do
        kubectl logs $pod -c $container > $logdir/$pod/$container.log
        kubectl logs $pod -c $container --previous > $logdir/$pod/$container-previous.log
        if [ $(eval echo $?) == 1 ]; then
            rm $logdir/$pod/$container-previous.log
        fi
    done
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/hosts" > $logdir/$pod/${containers[0]}-host-description.log
    kubectl exec $pod -c ${containers[0]} -it -- bash -c "cat /etc/resolv.conf" > $logdir/$pod/${containers[0]}-resolv-description.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# OAUTH LOGS
mkdir $logdir/$oauthlogdir/kube-system
pods=$(eval $oauthcommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$oauthlogdir/kube-system/$pod
    kubectl -n kube-system describe pod $pod > $logdir/$oauthlogdir/kube-system/$pod/pod-describe.log
    kubectl -n kube-system logs $pod > $logdir/$oauthlogdir/kube-system/$pod/oauth.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

oauthcommand="${command//__component__/${ui_component_name}}"
pods=$(eval $oauthcommand)
for pod in $pods; do
    if [[ "$pod" =~ "ui-oauth2" ]];then
        echo -n -e $pod
        mkdir -p $logdir/$oauthlogdir/$pod
        kubectl describe pod $pod > $logdir/$oauthlogdir/$pod/pod-describe.log
        kubectl logs $pod > $logdir/$oauthlogdir/$pod/oauth.log
        echo -e "\033[0;32m [DONE]\033[0m"
    else 
       echo "Ignoring $pod"
    fi
done

# NETWORK POLICIES
netpols=$(eval $netpolcommand)
for netpol in $netpols; do
    echo -n -e $netpol
    kubectl describe netpol $netpol > $logdir/$netpollogdir/$netpol-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# SERVICES
services=$(eval $servicecommand)
for service in $services; do
    echo -n -e $service
    kubectl describe svc $service > $logdir/$servicelogdir/$service-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# NODE
nodes=$(eval $nodecommand)
for node in $nodes; do
    echo -n -e $node
    kubectl describe nodes $node > $logdir/$nodelogdir/$node-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# CONFIGMAP
echo -n -e "configmap log"
$(eval $configmapcommand > $logdir/configmap-list.log)
echo -e "\033[0;32m [DONE]\033[0m"

# SECRET
echo -n -e "secret log"
$(eval $secretcommand > $logdir/secret-list.log)
echo -e "\033[0;32m [DONE]\033[0m"

# TILLER
echo -n -e "tiller logs"
kubectl get pods -n kube-system | grep tiller > $logdir/$tillerlogdir/kube-system-tiller.log
tillercommand="$kubesystemcommand | grep tiller"
tillerpod=$(eval $tillercommand)
kubectl logs ${tillerpod} -n kube-system | grep es > $logdir/$tillerlogdir/tiller.log
echo -e "\033[0;32m [DONE]\033[0m"

# HELM
if [ -z "${RELEASE}" ]; then
    echo "Please provide the release name to retrieve the helm logs"
else
    echo -n -e "helm logs"
    helm history ${RELEASE} --tls > $logdir/$helmlogdir/helm_hist.log
    helm get values ${RELEASE} --tls > $logdir/$helmlogdir/helm_values.log
    linecert=$(eval grep -n -w "cert:" $logdir/$helmlogdir/helm_values.log | cut -f1 -d:)
    linekey=$(eval grep -n -w "key:" $logdir/$helmlogdir/helm_values.log | cut -f1 -d:)
    sed -i '' -e "${linecert}s/.*/  cert: REDACTED/" $logdir/$helmlogdir/helm_values.log
    sed -i '' -e "${linekey}s/.*/  key: REDACTED/" $logdir/$helmlogdir/helm_values.log
    echo -e "\033[0;32m [DONE]\033[0m"
fi

# ICP CONFIGMAP
echo -n -e "ICP configmap log"
icpconfigmap=$(eval $icpconfigmapcommand)
kubectl describe configmap ${icpconfigmap} -n kube-public > $logdir/$icpconfigmap-configmap.log
echo -e "\033[0;32m [DONE]\033[0m"

# PV
echo -n -e "pv logs"
kubectl get pv > $logdir/$pvlogdir/pv.log
pvs=$(eval $pvcommand)
for pv in $pvs; do
    echo -n -e $pv
    kubectl describe pv $pv > $logdir/$pvlogdir/$pv-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# PVC
pvcs=$(eval $pvccommand)
if [ -z "${pvcs}" ]; then
    echo -n -e "No pvcs to gather logs for"
    echo -e "\033[0;32m [DONE]\033[0m"
else
    echo -n -e "pvc logs"
    kubectl get pvc > $logdir/$pvclogdir/pvc.log
    for pvc in $pvcs; do
        echo -n -e $pvc
        kubectl describe pvc $pvc > $logdir/$pvclogdir/$pvc-describe.log
        echo -e "\033[0;32m [DONE]\033[0m"
    done
fi

# KUBE-DNS
echo -n -e "kube-dns logs"
kubednscommand="$kubesystemcommand  | grep kube-dns"
kubednspods=$(eval $kubednscommand)
for pod in $kubednspods; do
    echo -n -e $pod
    kubectl logs $pod -n kube-system > $logdir/$kubednslogdir/$pod.log
    kubectl describe pod $pod -n kube-system > $logdir/$kubednslogdir/$pod-describe.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# CERTIFICATE VALUES
echo -n -e "certificates"
proxysecret=$(eval $secretcommand | grep proxy-secret)
secretjsoncommand='kubectl get secret -o json $proxysecret'
certificatefields=(https.cert podtls.cert podtls.cacert tls.cert tls.cluster tls.cacert)
for field in ${certificatefields[@]}; do
    echo -n -e $field
    $(eval $secretjsoncommand | jq '.data | ."'$field'"' | sed 's/\"//g'| base64 --decode | openssl x509 -text > $logdir/$certificatedir/$field)
    echo -e "\033[0;32m [DONE]\033[0m"
done

# CERT-GEN
mkdir $logdir/$certgenlogdir/kube-system
pods=$(eval $certgencommand)
for pod in $pods; do
    echo -n -e $pod
    kubectl -n kube-system describe pod $pod > $logdir/$certgenlogdir/kube-system/$pod/pod-describe.log
    kubectl -n kube-system logs $pod > $logdir/$certgenlogdir/kube-system/$pod/$pod.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

certgencommand="${command//__component__/${essential_component_name}}"
pods=$(eval $certgencommand)
for pod in $pods; do
    echo -n -e $pod
    mkdir -p $logdir/$certgenlogdir/$pod
    kubectl describe pod $pod > $logdir/$certgenlogdir/$pod/pod-describe.log
    kubectl logs $pod > $logdir/$certgenlogdir/$pod/certgen.log
    echo -e "\033[0;32m [DONE]\033[0m"
done

# Tar the results
tar czf logs-$DATE.tar.gz $logdir
rm -rf $logdir
echo "COMPLETE - Results are in logs-$DATE.tar.gz"
