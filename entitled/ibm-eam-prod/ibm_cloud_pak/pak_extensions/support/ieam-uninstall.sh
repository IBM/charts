#!/bin/bash

# Usage: ./ieam-uninstall.sh <cluster-name> [optional release name override, default: ibm-edge]

# Script prerequisites
PREREQUISITES=( oc helm )
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
CLUSTER_NAME=$(oc get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_name}")
if [ -z $CLUSTER_NAME ]; then
  echo "Couldn't determine current cluster name, exiting ..."
  exit 1
fi

# Define our needed ENV vars
EDGE_NAMESPACE=kube-system  #Deploying to kube-system namespace to integrate the edge UI
EDGE_OC="oc --namespace $EDGE_NAMESPACE"
EDGE_RELEASE_NAME=${2:-ibm-edge}

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
       "\nRe-run this script passing the cluster name as an argument if you are -sure- you want to uninstall IBM Edge Application Manager from that cluster, exiting ..."
  usage
fi

# Ensuring they both match
if [[ $CLUSTER_NAME != $SUPPLIED_CLUSTER_NAME ]]; then
  echo "The current cluster '$CLUSTER_NAME' does not match the supplied cluster '$SUPPLIED_CLUSTER_NAME', exiting ..."
  usage
fi

# First prompt to the user
echo -e "\nWARNING: You will be uninstalling the IBM Edge Application Manager from the cluster '$CLUSTER_NAME',
This will delete -ALL- helm and kubernetes resources associated with the helm release '$EDGE_RELEASE_NAME'.  Are you sure you want to continue? [y/N]:"
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

COUNT=0
GET_EDGE_PODS="$EDGE_OC get pods | grep $EDGE_RELEASE_NAME"
while [[ $(eval $GET_EDGE_PODS) && $(eval $GET_EDGE_PODS | grep -vE "Completed|OOMKilled|Error") && $COUNT -lt 30 ]]; do
  $EDGE_OC get pods -o wide | grep $EDGE_RELEASE_NAME | grep -vE "Completed|OOMKilled|Error"
  echo -e "\nWaiting 15s for all pods above to terminate $COUNT/30 retries"
  COUNT=$((COUNT+1))
  if [ $COUNT != 30 ]; then
    sleep 15
  fi
done

# Did we timeout
if [[ $COUNT -eq 30 ]]; then
  echo "The pods above have not terminated, giving up. Please identify the issue with the $EDGE_RELEASE_NAME pod and re-run this script when resolved"
  exit 1
else
  echo "All pods have terminated"
fi
echo ""
# Sometimes our failed jobs are left hanging around, remove them if they exist
if $EDGE_OC get job | grep $EDGE_RELEASE_NAME > /dev/null 2>&1; then
  echo "Deleting all $EDGE_RELEASE_NAME jobs"
  for JOB in $($EDGE_OC get job | grep $EDGE_RELEASE_NAME | awk '{print $1}'); do
     $EDGE_OC delete job $JOB
  done
  REMAINING_JOB=$($EDGE_OC get job | grep $EDGE_RELEASE_NAME)
  check_resources "$REMAINING_JOB" "jobs"
fi
# The helm test pod as well
$EDGE_OC delete pod $EDGE_RELEASE_NAME-service-verification $EDGE_RELEASE_NAME-agbotdb-test $EDGE_RELEASE_NAME-cssdb-test $EDGE_RELEASE_NAME-exchangedb-test
echo ""

# Deleting all persistent volume content and data
echo "Deleting all $EDGE_RELEASE_NAME persistent volume claims"
for CLAIM in $($EDGE_OC get pvc |grep -E 'agbot|exchange|css' | awk '{print $1}'); do
  $EDGE_OC delete pvc $CLAIM
done
REMAINING_PVC=$($EDGE_OC get pvc | grep -E 'agbot|exchange|css')
check_resources "$REMAINING_PVC" "persistent volume claims"

echo "Deleting all $EDGE_RELEASE_NAME persistent volumes"
for VOLUME in $($EDGE_OC get pv |grep -E 'agbot|exchange|css' | awk '{print $1}'); do
  oc delete pv $VOLUME
done
REMAINING_PV=$($EDGE_OC get pv | grep -E 'agbot|exchange|css')
check_resources "$REMAINING_PV" "persistent volumes"

echo "Deleting all $EDGE_RELEASE_NAME config maps"
$EDGE_OC delete cm stolon-cluster-$EDGE_RELEASE_NAME-agbotdb stolon-cluster-$EDGE_RELEASE_NAME-exchangedb $EDGE_RELEASE_NAME-config
REMAINING_CONFIG_MAP=$($EDGE_OC get cm |grep $EDGE_RELEASE_NAME)
check_resources "$REMAINING_CONFIG_MAP" "config maps"

echo ""
# Deleting our secrets
echo "Deleting $EDGE_RELEASE_NAME secrets"
$EDGE_OC delete secret $EDGE_RELEASE_NAME-auth $EDGE_RELEASE_NAME-auth-backup $EDGE_RELEASE_NAME-remote-dbs $EDGE_RELEASE_NAME-agbotdb-auth-secret $EDGE_RELEASE_NAME-cssdb-auth-secret $EDGE_RELEASE_NAME-exchangedb-auth-secret

REMAINING_SECRET=$($EDGE_OC get secret | grep "$EDGE_RELEASE_NAME ")
check_resources "$REMAINING_SECRET" "secrets"

echo "Deleting database service account policy role binding for internal registry pulls"
for DB_SA in agbot exchange css; do
  oc policy remove-role-from-user system:image-puller system:serviceaccount:kube-system:$EDGE_RELEASE_NAME-${DB_SA}db --namespace=ibmcom
done
echo "Deleting IEAM service account policy role binding for internal registry pulls"
oc policy remove-role-from-user system:image-puller system:serviceaccount:kube-system:$EDGE_RELEASE_NAME-application-manager --namespace=ibmcom

if [[ $POSSIBLE_DATA_REMNANTS == true ]]; then
  echo -e "\n$EDGE_RELEASE_NAME was mostly uninstalled, please see above for a WARNING note. If this is not the first time running uninstallation, this can likely be ignored\n"
else
  echo -e "\n$EDGE_RELEASE_NAME was successfully uninstalled\n"
fi
