#!/bin/bash

# Usage: ./uninstall-edge-computing.sh <cluster-name>

# Script prerequisites
PREREQUISITES=( kubectl helm )
# Checking prerequisites
function check_prereqs(){
  echo "Checking for prerequisites"
  for i in "${PREREQUISITES[@]}"; do
    if ! command -v ${i} >/dev/null 2>&1; then
      echo "'${i}' not found. Please install this prerequisite, exiting ..."
      exit 1
    fi
  done
}
check_prereqs

# Usage
function usage(){
  echo -e "\nUsage: $0 <cluster name>\n"
  exit 1
}

# Determining cluster name from current context
echo "Gathering some data about your cluster"
CLUSTER_NAME=$(kubectl config current-context | awk -F '-context' '{print $1}')
if [ -z $CLUSTER_NAME ]; then
  echo "Couldn't determine current cluster name, exiting ..."
  exit 1
fi

MASTER=$(kubectl get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_address}")
if [ -z $MASTER ]; then
  echo "Couldn't determine master node, are you connected to a cluster?"
  exit 1
fi

# Define our needed ENV vars
EDGE_NAMESPACE=kube-system  #Deploying to kube-system namespace to integrate the edge UI
EDGE_KUBECTL="kubectl --namespace $EDGE_NAMESPACE"
EDGE_RELEASE_NAME=edge-computing

# Helper function to ensure all requested uninstallations removed the required content
function check_resources(){
  REMAINING_RESOURCES="$1"
  TYPE="$2"

  if [[ -n $REMAINING_RESOURCES ]]; then
    echo $REMAINING_RESOURCES
    echo -e "\nOne or more $TYPE above weren't deleted successfully, please resolve any issues and run the uninstallation again, exiting ..."
    exit 1
  else
    echo -e "All $EDGE_RELEASE_NAME $TYPE removed\n"
  fi
}

# Ensuring user has supplied a cluster name to compare
SUPPLIED_CLUSTER_NAME=$1
if [[ -z $SUPPLIED_CLUSTER_NAME ]]; then
  echo -e "No cluster name supplied, current connected cluster name is: '$CLUSTER_NAME'" \
       "\nRe-run this script passing the cluster name as an argument if you are -sure- you want to uninstall IBM Edge Computing from that cluster, exiting ..."
  usage
fi

# Ensuring they both match
if [[ $CLUSTER_NAME != $SUPPLIED_CLUSTER_NAME ]]; then
  echo "The current cluster '$CLUSTER_NAME' does not match the supplied cluster '$SUPPLIED_CLUSTER_NAME', exiting ..."
  usage
fi

# First prompt to the user
echo -e "\nWARNING: You will be uninstalling the IBM Edge Computing infrastructure from the cluster '$CLUSTER_NAME',
This will delete -ALL- helm and kubernetes resources associated with the helm release '$EDGE_RELEASE_NAME'.  Are you sure you want to continue?[y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi

# Checking helm connection
echo "Ensuring a valid helm connection"
helm ls --tls > /dev/null
if [ $? != 0 ]; then
  echo "There was a problem reaching tiller, please resolve any issues and run the uninstallation again, exiting ..."
  exit 1
fi

echo -e "\nDeleting ALL '$EDGE_RELEASE_NAME' resources, errors are -OK- and are only printed to assist with debugging.\n"
sleep 5

# Delete the helm release
echo "Deleting the $EDGE_RELEASE_NAME helm release"
helm delete --purge $EDGE_RELEASE_NAME --tls
REMAINING_RELEASES=$(helm ls --tls | grep "$EDGE_RELEASE_NAME ")
check_resources "$REMAINING_RELEASES" "helm releases"

# Sometimes our failed jobs are left hanging around, remove them if they exist
if $EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME > /dev/null 2>&1; then
  echo "Deleting all $EDGE_RELEASE_NAME jobs"
  for JOB in $($EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME | awk '{print $1}'); do
     $EDGE_KUBECTL delete job $JOB
  done
  REMAINING_JOB=$($EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME)
  check_resources "$REMAINING_JOB" "jobs"
fi
# The helm test pod as well
$EDGE_KUBECTL delete pod $EDGE_RELEASE_NAME-service-verification

# Deleting our secrets
echo "Deleting $EDGE_RELEASE_NAME secrets"
$EDGE_KUBECTL delete secret $EDGE_RELEASE_NAME $EDGE_RELEASE_NAME-backup edge-computing-remote-dbs

REMAINING_SECRET=$($EDGE_KUBECTL get secret | grep "$EDGE_RELEASE_NAME ")
check_resources "$REMAINING_SECRET" "secrets"

if [[ $POSSIBLE_DATA_REMNANTS == true ]]; then
  echo -e "\n$EDGE_RELEASE_NAME was mostly uninstalled, please see above for a WARNING note. If this is not the first time running uninstallation, this can likely be ignored\n"
else
  echo -e "\n$EDGE_RELEASE_NAME was successfully uninstalled\n"
fi
