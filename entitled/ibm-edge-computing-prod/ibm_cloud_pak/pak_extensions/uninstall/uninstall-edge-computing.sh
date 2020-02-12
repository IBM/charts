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
WORKER_IP=$($EDGE_KUBECTL get nodes -l node-role.kubernetes.io/worker=true --no-headers | cut -f1 -d " ")
DISK_ROOT_PATH=/mnt/disk/$EDGE_RELEASE_NAME/$EDGE_RELEASE_NAME

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
This will delete -ALL- helm and kubernetes resources associated with the helm release '$EDGE_RELEASE_NAME'.  Are you sure you want to continue? [y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi

echo "Do you want backup your database and secrets to a different folder prior to deletion?  Contents will be moved to a different folder on the worker's local storage. [y/N]"
read RESPONSE
if [ "$RESPONSE" == 'y' ]; then
  if [[ -z $WORKER_IP ]]; then
    echo -e "\nWARNING: WORKER_IP is not defined, unable backup secrets and databases.\nDo you want to continue uninstalling? [y/N]"
    read RESPONSE
    if [ "$RESPONSE" == 'y' ]; then
      echo "Cancelling uninstall at user's request."
      exit 0
    fi
  else
    BACKUP_TIME=$(date +%Y%m%d_%H%M%S)
    echo "Backing up your databases and secrets to /mnt/edge_backup/edge-computing_backup_$BACKUP_TIME/ on worker node $(echo $WORKER_IP | awk '{print $1}')."
    # Saving Secrets
    ssh -t root@$MASTER "mkdir -p /tmp/backup;
      $EDGE_KUBECTL get secret edge-computing -o yaml > /tmp/backup/$EDGE_RELEASE_NAME-backup.yaml;
      $EDGE_KUBECTL get secret edge-computing-agbotdb-postgresql-auth-secret -o yaml > /tmp/backup/$EDGE_RELEASE_NAME-agbotdb-postgresql-auth-secret-backup.yaml;
      $EDGE_KUBECTL get secret edge-computing-css-db-ibm-mongodb-auth-secret -o yaml > /tmp/backup/$EDGE_RELEASE_NAME-css-db-ibm-mongodb-auth-secret-backup.yaml;
      $EDGE_KUBECTL get secret edge-computing-exchangedb-postgresql-auth-secret -o yaml > /tmp/backup/$EDGE_RELEASE_NAME-exchangedb-postgresql-auth-secret-backup.yaml;
      ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mkdir -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/css-backup; mkdir -p /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/secrets/';
      scp /tmp/backup/*  $(echo $WORKER_IP | awk '{print $1}'):/mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/secrets/;
      rm -rf /tmp/backup" > /dev/null 2>&1
    # Saving databases
    $EDGE_KUBECTL exec edge-computing-exchangedb-keeper-0 -- bash -c "export PGPASSWORD=$($EDGE_KUBECTL get secret edge-computing -o jsonpath="{.data.exchange-db-pass}" | base64 --decode); pg_dump -U admin -h edge-computing-exchangedb-proxy-svc -F t postgres > /stolon-data/exchangedbbackup.tar" > /dev/null 2>&1;
    $EDGE_KUBECTL exec edge-computing-agbotdb-keeper-0 -- bash -c "export PGPASSWORD=$($EDGE_KUBECTL get secret edge-computing -o jsonpath="{.data.agbot-db-pass}" | base64 --decode); pg_dump -U admin -h edge-computing-agbotdb-proxy-svc -F t postgres > /stolon-data/agbotdbbackup.tar" > /dev/null 2>&1;
    $EDGE_KUBECTL exec edge-computing-cssdb-server-0 -- bash -c "mkdir -p /data/db/backup; mongodump -u admin -p $($EDGE_KUBECTL get secret edge-computing -o jsonpath="{.data.css-db-pass}" | base64 --decode) --out /data/db/backup" > /dev/null 2>&1
    ssh -t root@$MASTER "ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-exchange/exchangedbbackup.tar /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/';
    ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-agbot/agbotdbbackup.tar /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/';
    ssh -tt $(echo $WORKER_IP | awk '{print $1}') 'mv /mnt/disk/${EDGE_RELEASE_NAME}/${EDGE_RELEASE_NAME}-css/backup/* /mnt/edge_backup/${EDGE_RELEASE_NAME}_backup_${BACKUP_TIME}/db-backup/css-backup/';" > /dev/null 2>&1
  fi
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
GET_EDGE_PODS="$EDGE_KUBECTL get pods | grep $EDGE_RELEASE_NAME"
while [[ $(eval $GET_EDGE_PODS) && $(eval $GET_EDGE_PODS | grep -v "Completed") && $COUNT -lt 30 ]]; do
  $EDGE_KUBECTL get pods -o wide | grep $EDGE_RELEASE_NAME | grep -v Completed
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
if $EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME > /dev/null 2>&1; then
  echo "Deleting all $EDGE_RELEASE_NAME jobs"
  for JOB in $($EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME | awk '{print $1}'); do
     $EDGE_KUBECTL delete job $JOB
  done
  REMAINING_JOB=$($EDGE_KUBECTL get job | grep $EDGE_RELEASE_NAME)
  check_resources "$REMAINING_JOB" "jobs"
fi
# The helm test pod as well
$EDGE_KUBECTL delete pod $EDGE_RELEASE_NAME-service-verification $EDGE_RELEASE_NAME-agbotdb-test $EDGE_RELEASE_NAME-cssdb-test $EDGE_RELEASE_NAME-exchangedb-test
echo ""

# Deleting all persistent volume content and data
echo "Deleting all $EDGE_RELEASE_NAME persistent volume claims"
for CLAIM in $($EDGE_KUBECTL get pvc |grep -E 'agbot|exchange|css' | awk '{print $1}'); do
  $EDGE_KUBECTL delete pvc $CLAIM
done
REMAINING_PVC=$($EDGE_KUBECTL get pvc | grep -E 'agbot|exchange|css')
check_resources "$REMAINING_PVC" "persistent volume claims"

echo "Deleting all $EDGE_RELEASE_NAME persistent volumes"
for VOLUME in $($EDGE_KUBECTL get pv |grep -E 'agbot|exchange|css' | awk '{print $1}'); do
  kubectl delete pv $VOLUME
done
REMAINING_PV=$($EDGE_KUBECTL get pv | grep -E 'agbot|exchange|css')
check_resources "$REMAINING_PV" "persistent volumes"

echo "Deleting all $EDGE_RELEASE_NAME config maps"
$EDGE_KUBECTL delete cm stolon-cluster-$EDGE_RELEASE_NAME-agbotdb stolon-cluster-$EDGE_RELEASE_NAME-exchangedb
REMAINING_CONFIG_MAP=$($EDGE_KUBECTL get cm |grep $EDGE_RELEASE_NAME)
check_resources "$REMAINING_CONFIG_MAP" "config maps"

if [[ -z $WORKER_IP ]]; then
  echo -e "\nWARNING: WORKER_IP is not defined, unable to identify where physical data may be stored.\nPhysical data may still exist on a worker node, likely at $($EDGE_KUBECTL get nodes -l node-role.kubernetes.io/worker | grep -m 1 Ready | awk '{print $1}'):$DISK_ROOT_PATH*\n"
  POSSIBLE_DATA_REMNANTS=true
else
  echo "Deleting all $EDGE_RELEASE_NAME physically stored data"
  for WORKER in $WORKER_IP; do
    ssh root@$MASTER "ssh $WORKER rm -rf $DISK_ROOT_PATH-agbot $DISK_ROOT_PATH-css $DISK_ROOT_PATH-exchange"
  done
  if [ $? != 0 ]; then
    echo "There was a problem removing physically stored data on '$WORKER_IP' via '$MASTER' as root, please resolve any connection issues and run the uninstallation again, exiting ..."
    exit 1
  else
    echo "$EDGE_RELEASE_NAME physically stored data was removed"
  fi
fi
echo ""
# Deleting our secrets
echo "Deleting $EDGE_RELEASE_NAME secrets"
$EDGE_KUBECTL delete secret $EDGE_RELEASE_NAME $EDGE_RELEASE_NAME-backup $EDGE_RELEASE_NAME-remote-dbs $EDGE_RELEASE_NAME-agbotdb-postgresql-auth-secret $EDGE_RELEASE_NAME-css-db-ibm-mongodb-auth-secret $EDGE_RELEASE_NAME-exchangedb-postgresql-auth-secret

REMAINING_SECRET=$($EDGE_KUBECTL get secret | grep "$EDGE_RELEASE_NAME ")
check_resources "$REMAINING_SECRET" "secrets"


if [[ $POSSIBLE_DATA_REMNANTS == true ]]; then
  echo -e "\n$EDGE_RELEASE_NAME was mostly uninstalled, please see above for a WARNING note. If this is not the first time running uninstallation, this can likely be ignored\n"
else
  echo -e "\n$EDGE_RELEASE_NAME was successfully uninstalled\n"
fi
