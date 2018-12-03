#!/bin/bash
#
# Licensed Materials - Property of IBM
#
# 5737-H33
#
# (C) Copyright IBM Corporation 2018 All Rights Reserved
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with IBM Corp.


#############################
# Syntax for running script ./<scriptname> <Releasename> <namespace>
# Must be logged into kubernetes cluster before executing this script, see following command
# cloudctl login -a https://<master-node-external-ip>:<port>
#############################

# Print event data in an easily readable format
filterevents() {
while read line ; do
    echo '------------------'
    NAME=$(echo $line | awk '{printf $4}' | cut -d. -f1)
    TYPE=$(echo $line | awk '{printf $5}')
    FIRSTSEEN=$(echo $line | awk '{printf $2}')
    LASTSEEN=$(echo $line | awk '{printf $1}')
    ISSUE=$(echo $line | awk '{for(i=9;i<=NF;++i)printf $i""FS ; print ""}' | sed -e 's/ /~/g')
    ISSUE=$(echo $ISSUE | sed -e 's/~/ /g')
    echo -e "Name: $NAME\nType: $TYPE\nFirstSeen: $FIRSTSEEN\nLastSeen: $LASTSEEN\nIssue: $ISSUE"
done
}

# Event data by default saved for an hour, If a pod is older than an hour delete it so that it will get redeployed and the events will occur again
restartPodsIfOld() {
    waitPod=false
    if $RESTARTOLDPODS; then 
        for pod in $@
        do
            age=$(kubectl get pod -n$NAMESPACE $pod | awk '{printf $5 "\n"}' | grep -e '[h|d]' | cat)
            if [[ $age ]]; then
            echo "Pod older than 1 hour, restarting pod $pod"
            kubectl delete pod $pod
            waitPods=true
            fi
        done
        if [[ $waitPods ]]; then
        echo 'Sleeping for 60 seconds while pods restart.'
        sleep 60
        fi
    fi
}

checkReleasenameAndNamespaceValid() {
pods=$(kubectl get pods -n$NAMESPACE -l release=$RELEASENAME 2>&1)
if [[ $pods == "No resources found." ]]; then
    echo -e "No pods could be found in Namespace: $NAMESPACE with Releasename: $RELEASENAME\nPlease check correct values have been supplied to this script"
    exit 1
fi
}

# If api-key in ibm-es-iam-secret does not exist print message and exit as this will be the cause of a lot of problems.
checkIamSecretApiKeyExists() {
echo "Checking the ibm-es-iam-secret API Key..."
iamSecretName=$(kubectl get secrets -n$NAMESPACE --no-headers -l app=ibm-es,component=security,release=$RELEASENAME -o custom-columns=NAME:.metadata.name)
apiKeyName=$(kubectl get secrets -n$NAMESPACE $iamSecretName -o jsonpath="{.metadata.annotations['ibm\.com/iam-service\.api-key']}")
apiKeyValue=$(kubectl get secrets -n$NAMESPACE $iamSecretName -o jsonpath="{.data['$apiKeyName']}")
if [[ -z $apiKeyValue ]]; then
    echo "No api-key found in [$iamSecretName] secret, please contact support."
    exit 1
else
    echo "API Key found"
fi
}

# If no kafka or zookeeper pods are found, get Failed events for the release
# Kafka and zookeeper pods do not appear if the resource request for these was greater than the limits set for them
# the stateful sets produce failedcreate events in this case
checkKafkaZookeeperPodsPresent() {
kafkaPresent=$(kubectl get pods -n$NAMESPACE -l component=kafka,release=$RELEASENAME 2>&1)
zookPresent=$(kubectl get pods -n$NAMESPACE -l component=zookeeper,release=$RELEASENAME 2>&1)

# If no kafka pods found
echo "Checking kafka-sts pods..."
if [[ $kafkaPresent == "No resources found." ]]; then
    foundIssue=true
    echo 'Could not find kafka-sts pods.'
    kubectl get events -n$NAMESPACE --field-selector reason=FailedCreate | grep $RELEASENAME | filterevents
    echo '------------------'
else
    echo "kafka-sts pods found"
fi

# If no Zookeeper pods found
echo "Checking zookeeper-sts pods..."
if [[ $zookPresent == "No resources found." ]]; then
    foundIssue=true
    echo 'Could not find zookeeper-sts pods.'
    kubectl get events -n$NAMESPACE --field-selector reason=FailedCreate | grep $RELEASENAME | filterevents
    echo '------------------'
else
    echo "zookeeper-sts pods found"
fi
}

# If found pods in "Failed" state, get reason and msg from describe
checkPodsInFailedState() {
podsFailed=($(kubectl get pods -n$NAMESPACE -o jsonpath='{.items[?(@.status.phase=="Failed")].metadata.name}'))
if [[ $podsFailed ]]; then
    foundIssue=true
    echo 'Failed pods found, checking pod events...'
    restartPodsIfOld ${podsPending[@]}
    for pod in ${podsFailed[@]}
    do
        failedMessage=$(kubectl get pod -n$NAMESPACE $pod -o jsonpath='{.status.message}')
        failedReason=$(kubectl get pod -n$NAMESPACE $pod -o jsonpath='{.status.reason}')
        failedAge=$(kubectl get pod -n$NAMESPACE $pod --no-headers | awk '{printf $5}')
        echo '------------------'
        echo -e "Pod: $pod\nAge: $failedAge\nReason: $failedReason\nMessage: $failedMessage "
    done
    echo '------------------'
fi
} 

# If found pods in "Pending" state, get Failed events for those pods
checkPodsInPendingState() {
echo "Checking for Pending pods..."
podsPending=($(kubectl get pods -n$NAMESPACE -l release=$RELEASENAME -o jsonpath='{.items[?(@.status.phase=="Pending")].metadata.name}'))
if [[ $podsPending ]]; then
    foundIssue=true
    echo 'Pending pods found, checking pod for failed events...'
    restartPodsIfOld ${podsPending[@]}
    for pod in ${podsPending[@]}
    do
        podsPendingAbnormalEvents=$(kubectl get events -n$NAMESPACE --field-selector involvedObject.name=$pod | grep Failed)
        if [[ $podsPendingAbnormalEvents ]]; then
            echo $podsPendingAbnormalEvents | filterevents
        else
            echo '------------------'
            echo "No failed events found for pod $pod"
        fi
    done
    echo '------------------'
else
    echo "No Pending pods found"
fi
}

# If found a BackOff event and those pods are still in backoff state, print last lines of logs
checkPodsInCrashLoopBackOff() {
echo "Checking for CrashLoopBackOff pods..."
podsCrashLoopBackoff=($(kubectl get events -n$NAMESPACE --field-selector reason=BackOff 2>&1| grep $RELEASENAME | awk '{printf $4 "\n"}' | cut -d. -f1))
if [[ $podsCrashLoopBackoff ]]; then
    foundIssue=true
    echo 'CrashloopBackOff event found, investigating...'
    n=0
    while [[ ${podsCrashLoopBackoff[@]} && $n -lt 10 ]] 
    do
        for i in "${!podsCrashLoopBackoff[@]}"
        do
            podStatus=$(kubectl get pod -n$NAMESPACE ${podsCrashLoopBackoff[$i]} | grep CrashLoopBackOff | cat)
            badContainers=($(kubectl get pod -n$NAMESPACE ${podsCrashLoopBackoff[$i]} -o jsonpath='{.status.containerStatuses[?(@.ready==false)].name}'))
            if [[ $podStatus ]]; then
                echo "------------------------"
                echo "Printing logs for pod ${podsCrashLoopBackoff[$i]} found to be in CrashLoopBackOff state."
                echo '------------------------'
                for container in ${badContainers[@]}
                do
                    echo "Container: $container"
                    echo "-"
                    kubectl logs -n$NAMESPACE ${podsCrashLoopBackoff[$i]} $container | tail -n 15
                    echo '----------'
                done
                unset podsCrashLoopBackoff[$i] 
            fi
        done
        if [[ ${podsCrashLoopBackoff[@]} ]]; then
            sleep 10
        fi
        n=$((n+1))
        if [[ $n -eq 10 ]]; then
            echo -e "kubectl events indicates that pods have entered BackOff state, however logs can not be collected.\nIf containers continue to report CrashLoopBackOff, please manually run `kubectl logs` against the failing container(s) for more information"
        fi
    done
    echo '------------------------'
else
    echo "No CrashLoopBackOff pods found"
fi
}

# In case of none of the above issues, look for containers that aren't ready and print their logs
checkContainersNotReady() {
echo "Checking for containers that are not ready..."
pods=($(kubectl get pods -n$NAMESPACE -l release=$RELEASENAME -oname ))
foundBadContainers=false
for pod in ${pods[@]}
do  
    name=$pod
    readyFraction=($(kubectl get $pod -n$NAMESPACE --no-headers | awk '{printf $2}' | sed -e 's/\// /g'))
    if [[ ${readyFraction[0]} != ${readyFraction[1]} ]]; then
        foundBadContainers=true
        badContainers=($(kubectl get $pod -n$NAMESPACE -o jsonpath='{.status.containerStatuses[?(@.ready==false)].name}'))
        for container in ${badContainers[@]}
        do
            echo '------------------------'
            echo "Found container $container in pod $pod to be in an non ready state"
            echo "Printing the end of the logs for these containers"
            echo "-"
            kubectl logs -n$NAMESPACE $pod $container | tail -n 15
            echo "-"
        done
    fi
done
if ! $foundBadContainers; then
    echo "All the containers are ready"
fi
echo '------------------------'
}

printUsage() {
    echo "This script attempts to provide concise issues which would cause your install to fail."
    echo " "
    echo "installation-diagnostic-script [-n namespace] [-r releasename] [options]"
    echo " "
    echo "options"
    echo "--help, -h            Show brief help"
    echo "--namespace, -n       Provide the namespace for the install"
    echo "--releasename, -r     Provide the release name for the install"
    echo "--restartoldpods      Restart pods that are in pending state and more than an hour old to regenerate events"
}

###########################################################
# beginning of script
###########################################################
NAMESPACE=''
RELEASENAME=''
foundIssue=false
RESTARTOLDPODS=false

while [ ! $# -eq 0 ]
do
	case "$1" in
		--namespace | -n)
            shift
			NAMESPACE=$1
			shift
			;;
		--releasename | -r)
			shift
            RELEASENAME=$1
			shift
			;;
        --restartoldpods)
            shift
            RESTARTOLDPODS=true
            ;;
        --help | -h)
            shift
            printUsage
            exit 0
            ;;
        *)
            shift
            echo "Incorrect usage!"
            echo " "
            printUsage
            exit 0
            ;;
	esac
done

if [ -z ${NAMESPACE} ]; then
    read -p "Namespace : " NAMESPACE
fi 

if [ -z ${RELEASENAME} ]; then
    read -p "Chart releasename : " RELEASENAME
fi 

echo 'Starting release diagnostics...'
checkReleasenameAndNamespaceValid

checkKafkaZookeeperPodsPresent

checkIamSecretApiKeyExists

checkPodsInPendingState

checkPodsInFailedState

checkPodsInCrashLoopBackOff

if ! $foundIssue; then 
    checkContainersNotReady
fi

if $foundIssue; then 
    echo -e "Release diagnostics complete. Please review output to identify potential problems.\nIf unable to identify or fix problems, please contact support."
else
    echo -e "Release diagnostics complete. No issues found.\nIf problems continue, please contact support"
fi