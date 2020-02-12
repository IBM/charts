#!/bin/bash
set -e

# Usage: ./icp-edge-computing-install.sh [/optional/path/to/override/values.yaml] [optional.comma=separated,helm=values]

# NOTE: When adding overrides, one of those value overrides -must- contain global.image.repository, by default that is set
# to your connected clusters docker repository when no arguments are given

trap "echo -e '\nInstallation exited prematurely ...\n' && exit 1" ERR

echo "
By continuing you accept the terms and conditions of the IBM license stored in the LICENSES directory at the root of this chart, continue? [y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi

# Script prerequisites
PREREQUISITES=( docker jq make kubectl helm )
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

function die() {
    echo "$@" 1>&2
    exit 99
}

# Define our needed ENV vars
export EDGE_RELEASE_NAME=edge-computing
EDGE_NAMESPACE=kube-system  #Deploying to kube-system namespace to integrate the edge UI
EDGE_KUBECTL="kubectl --namespace $EDGE_NAMESPACE"
EDGE_DISK_ROOT=/mnt/disk/$EDGE_RELEASE_NAME

CLUSTER_NAME=$(kubectl get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_name}")
if [ -z $CLUSTER_NAME ]; then
  echo "Couldn't determine cluster name"
  exit 1
fi
EDGE_AGBOT_ID=${CLUSTER_NAME}-agbot

# Function to run helm installs
function helm_install(){
  HELM_RELEASE=$1
  HELM_LOCATION=$2
  HELM_VALUES_FILE_OVERRIDE=$3
  HELM_VALUES_SET=$4

  echo "Running: helm upgrade --install --force $HELM_RELEASE $HELM_LOCATION $HELM_VALUES_FILE_OVERRIDE $HELM_VALUES_SET --namespace $EDGE_NAMESPACE --tls"
  helm upgrade --install --force $HELM_RELEASE $HELM_LOCATION $HELM_VALUES_FILE_OVERRIDE $HELM_VALUES_SET --namespace $EDGE_NAMESPACE --tls
}

echo "Gathering some data about your cluster and install choices"
MASTER=$(kubectl get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_address}")

if [ -z $MASTER ]; then
  echo "Couldn't determine master node, are you connected to a cluster?"
  exit 1
fi

# Are we using local DB's, or remote ones ... cascading from set, to override values, to default values.yaml
SCRIPT_LOCATION=$(dirname "$0")
EDGE_DATABASE_CHOICE="remote"
FOUND=0
if [ -n "$1" ]; then
  if echo $2 2>&1 | grep "localDBs.enabled=true" > /dev/null 2>&1; then
    EDGE_DATABASE_CHOICE="local"
    FOUND=1
  else
    if echo $2 2>&1 | grep "localDBs.enabled=false" > /dev/null 2>&1; then
      FOUND=1
    fi
  fi
fi
if [ -n "$1" ] && [ $FOUND == 0 ]; then
  if cat $1 2>&1 | grep -A 1 localDBs | grep "enabled: true" > /dev/null 2>&1; then
    EDGE_DATABASE_CHOICE="local"
    FOUND=1
  else
    if cat $1 2>&1 | grep -A 1 localDBs | grep "enabled: false" > /dev/null 2>&1; then
      FOUND=1
    fi
  fi
fi
if [ $FOUND == 0 ]; then
  if cat $SCRIPT_LOCATION/../../../values.yaml 2>&1 | grep -A 1 localDBs | grep "enabled: true" > /dev/null 2>&1; then
    EDGE_DATABASE_CHOICE="local"
    FOUND=1
  else
    if cat $SCRIPT_LOCATION/../../../values.yaml 2>&1 | grep -A 1 localDBs | grep "enabled: false" > /dev/null 2>&1; then
      FOUND=1
    fi
  fi
fi
if [ $FOUND == 0 ]; then
  echo "Couldn't determine how databases are being deployed, please set the boolean 'localDBs.enabled'"
  exit 1
fi

# Check to ensure the expected secret exists
if [ $EDGE_DATABASE_CHOICE == "remote" ]; then
  if ! $EDGE_KUBECTL get secret $EDGE_RELEASE_NAME-remote-dbs  > /dev/null 2>&1; then
    echo "Setting value 'localDBs.enabled=false', but secret '$EDGE_RELEASE_NAME-remote-dbs' is not defined"
    echo -e "You will find directions for creating the secret in the README.md at the root of this chart\n"
    exit 1
  fi
fi

# Prompt user for confirmation
echo -e "\nYou will be deploying the IBM Edge Computing infrastructure to the cluster '$CLUSTER_NAME', continue? [y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi
# If the DB choice is local, we need to setup directory structure, persistent volumes, and claims
if [ $EDGE_DATABASE_CHOICE == "local" ]; then

  # Directory to store temporary files
  tmpDir=/tmp/createLocalVolumePV.$$
  mkdir -p $tmpDir
  # Temporary file, deleted at the end of the script
  tmpFile=$tmpDir/nodes.out

  echo "Fetching worker nodes available"
  kubectl get nodes -l node-role.kubernetes.io/worker=true --no-headers | cut -f1 -d " " > $tmpFile
  
  FOUND=0
  databaseHA=false

  if [ -n "$1" ]; then
    if echo $2 2>&1 | grep "global.databaseHA=true" > /dev/null 2>&1; then
      databaseHA="true"
      FOUND=1
    else
      if echo $2 2>&1 | grep "global.databaseHA=false" > /dev/null 2>&1; then
        FOUND=1
      fi
    fi
  fi
  if [ -n "$1" ] && [ $FOUND == 0 ]; then
    if cat $1 2>&1 | grep -A 1 databaseHA | grep "true" > /dev/null 2>&1; then
      databaseHA="true"
      FOUND=1
    else
      if cat $1 2>&1 | grep -A 1 databaseHA | grep "false" > /dev/null 2>&1; then
        FOUND=1
      fi
    fi
  fi
  if [ $FOUND == 0 ]; then
    if cat $SCRIPT_LOCATION/../../../values.yaml 2>&1 | grep -A 1 databaseHA | grep "true" > /dev/null 2>&1; then
      databaseHA="true"
      FOUND=1
    else
      if cat $SCRIPT_LOCATION/../../../values.yaml 2>&1 | grep -A 1 databaseHA | grep "false" > /dev/null 2>&1; then
        FOUND=1
      fi
    fi
  fi
  if [ $FOUND == 0 ]; then
    die "The database HA method was not set.  Please see the boolean databaseHA."
  fi

# Did we set HA without enough workers?
  nodeCount=$(cat $tmpFile | wc -l)
  if [[ $nodeCount -eq 0 ]]; then
    die "ERROR: no nodes were found that matched label -l node-role.kubernetes.io/worker=true"
  elif [[ $nodeCount -lt 3 ]]; then
    echo "Less than 3 worker nodes found. Using only the first worker node. HA databases have been disabled."
    databaseHA=false
    sed -i '1!d' $tmpFile
  fi

  SSH_ARGS="ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
  if [[ $databaseHA == "false" ]]; then
    sed -i '1!d' $tmpFile
    echo "Creating directory paths for persistent volumes, this will require a double ssh into one of your worker nodes via the master node as follows:"
    echo "$SSH_ARGS root@$MASTER '$SSH_ARGS $WORKER_IP mkdir -p $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-agbot $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-css $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-exchange'"
    while IFS= read -r WORKER_IP; do
      echo "Making directories on ${WORKER_IP}"
      ssh root@$MASTER "ssh $WORKER_IP mkdir -p $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-agbot $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-css $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-exchange" 
    done < $tmpFile
  elif [[ $databaseHA == "true" ]]; then
    sed -i '4,$d' $tmpFile
    echo "databaseHA was set to true, using the first 3 worker nodes for local persistent volumes"
    echo "Creating directory paths for persistent volumes, this will require a double ssh into one of your worker nodes via the master node as follows:"
    echo "$SSH_ARGS root@$MASTER '$SSH_ARGS $WORKER_IP mkdir -p $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-agbot $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-css $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-exchange'"
    while read -u10 WORKER_IP; do
      echo "Making directories on ${WORKER_IP}"
      ssh root@$MASTER "ssh $WORKER_IP mkdir -p $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-agbot $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-css $EDGE_DISK_ROOT/${EDGE_RELEASE_NAME}-exchange"
    done 10< $tmpFile
  fi
  while IFS= read -r WORKER_IP; do
    for SERVICE in agbot css exchange; do
      if [[ $SERVICE =~ "css" ]]; then
          VOLUME_SIZE=50
          STORAGE_CLASS=css-storage
        elif [[ $SERVICE =~ "agbot" ]]; then
          VOLUME_SIZE=10
          STORAGE_CLASS=agbot-storage
        else
          VOLUME_SIZE=10
          STORAGE_CLASS=exchange-storage
        fi

        if ! $EDGE_KUBECTL get pv ${SERVICE}-${WORKER_IP} > /dev/null 2>&1; then
          echo "Creating persistent volume ${SERVICE}-${WORKER_IP}"
          cat <<EOF | $EDGE_KUBECTL apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ${SERVICE}-${WORKER_IP}
spec:
  capacity:
    storage: ${VOLUME_SIZE}Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: ${STORAGE_CLASS}
  local:
    path: ${EDGE_DISK_ROOT}/${EDGE_RELEASE_NAME}-${SERVICE}
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $WORKER_IP
EOF
      else
        echo "Persistent volume ${SERVICE}-${WORKER_IP} already exists"
      fi
    done
  done < $tmpFile
  rm -fr $tmpDir
fi
# End volume creation
# Setting DB choice to remote for this release
SCRIPT_LOCATION=$(dirname "$0")

# Check to ensure the expected secret exists
if [ $EDGE_DATABASE_CHOICE == "remote" ]; then
  databaseHA=false
  if ! $EDGE_KUBECTL get secret edge-computing-remote-dbs  > /dev/null 2>&1; then
    echo "Setting value 'localDBs.enabled=false', but secret '$EDGE_RELEASE_NAME-remote-dbs' is not defined"
    echo -e "You will find directions for creating the secret in the README.md at the root of this chart\n"
    exit 1
  fi
fi

# Install the Edge Computing chart, there are three levels of arguments
# NOTE: If you use a method supplying override arguments, you -must- set the global.image.repository value or image pulls will fail
#
### No arguments; uses local cluster as global.image.repository and the defaults in values.yaml
# ./install-edge-computing.sh
#
### One argument; a path to a separate yaml which overrides the main chart values.yaml for matching values
# ./install-edge-computing.sh ../relative/or/full/path/to/overrides.yaml
#
### Two arguments; The first a path to a separate yaml for overriding defaults, the second for specific overrides after that
# ./install-edge-computing.sh /path/to/file.yaml exchange.replicaCount=3
#

if [ -z $1 ]; then
  helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "--set global.image.repository=$CLUSTER_NAME.icp:8500/kube-system,global.databaseHA=$databaseHA"
else
  if [ -z $2 ]; then
    helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "-f $1" "--set global.databaseHA=$databaseHA"
  else
    helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "-f $1" "--set $2,global.databaseHA=$databaseHA"
  fi
fi

# Trust the CA for the remaining REST calls
export CURL_CA_BUNDLE=/tmp/ca.crt
$EDGE_KUBECTL get secret cluster-ca-cert -o jsonpath="{.data['tls\.crt']}" | base64 --decode > $CURL_CA_BUNDLE
ICP_URL=https://$CLUSTER_NAME.icp:8443

# Before we check our new pods, lets clean up any old helm tests, failed or not
if $EDGE_KUBECTL get pod $EDGE_RELEASE_NAME-service-verification > /dev/null 2>&1; then
  $EDGE_KUBECTL delete pod $EDGE_RELEASE_NAME-service-verification
fi

if $EDGE_KUBECTL get pods | grep $EDGE_RELEASE_NAME | grep test | awk '{print $1}' > /dev/null 2>&1; then
    for test in $($EDGE_KUBECTL get pods | grep $EDGE_RELEASE_NAME | grep test | awk '{print $1}'); do
    $EDGE_KUBECTL delete pod $test
  done
fi


# Ensure there are release pods, and that they are all up and running
COUNT=0
GET_EDGE_PODS="$EDGE_KUBECTL get pods -o wide | grep $EDGE_RELEASE_NAME"
while [[ $(eval $GET_EDGE_PODS) && $(eval $GET_EDGE_PODS | grep -vE "Terminating|Completed" | grep '0/1') && $COUNT -lt 30 ]]; do
 CURRENT_PODS=$(eval $GET_EDGE_PODS | grep -vE "Terminating|Completed" | grep '0/1') || true
 if [ -z "$CURRENT_PODS" ]; then
   break;
  else
    echo -e "$CURRENT_PODS\n\nWaiting 15s for all pods above to be in a '1/1 Running' state $COUNT/30 retries"
    if $EDGE_KUBECTL get pods -o wide | grep $EDGE_RELEASE_NAME | grep -E 'ErrImagePull|ImagePullBackOff'; then
      echo "Exiting loop early due to image download error, run '$EDGE_KUBECTL describe pod <POD>' to determine failure reason. Resolve, then attempt re-install"
      exit 1
    fi
  fi
  COUNT=$((COUNT+1))
  if [ $COUNT != 30 ]; then
    sleep 15
  fi
done

# Did we timeout
if [[ $COUNT -eq 30 ]]; then
  echo "The pods above are still in a non-running state, giving up. Please identify the issue with the $EDGE_RELEASE_NAME pod and re-run this script when resolved"
  exit 1
else
  echo "All pods are in a running state"
fi

# Pull generated secrets into env variables
export EDGE_AGBOT_TOKEN=$(kubectl --namespace kube-system get secret $EDGE_RELEASE_NAME -o jsonpath="{.data.agbot-token}" | base64 --decode) \
EDGE_EXCHANGE_ROOT_PASS=$(kubectl --namespace kube-system get secret $EDGE_RELEASE_NAME -o jsonpath="{.data.exchange-root-pass}" | base64 --decode)

# Wait for the exchange to come online
COUNT=0
echo "Verifying the Exchange API is available $COUNT/20 retries"
while [[ $(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $ICP_URL/ec-exchange/v1/admin/status | jq -r .msg) != "Exchange server operating normally" && $COUNT -lt 20 ]]; do
  echo "Waiting 15s for the Exchange API to be available $COUNT/20 retries"
  COUNT=$((COUNT+1))
  if [ $COUNT != 20 ]; then
    sleep 15
  fi
done

# Did we timeout
if [[ $COUNT -eq 20 ]]; then
  echo "The Exchange API was unreachable after 5m, giving up. Please identify the issue with the $EDGE_RELEASE_NAME-exchange pod and re-run this script when resolved"
  exit 1
else
  echo "The Exchange API is up and running"
fi

# Create agbot section
function create_agbot() {
  if ! curl -sSf -X PUT -s -H Accept:application/json \
      -H Content-Type:application/json \
      -H "Authorization:Basic root/root:$EDGE_EXCHANGE_ROOT_PASS" \
      -d '{ "name": "'$EDGE_AGBOT_ID'", "token": "'$EDGE_AGBOT_TOKEN'", "publicKey": "", "msgEndPoint": ""}' \
      $ICP_URL/ec-exchange/v1/orgs/IBM/agbots/$EDGE_AGBOT_ID > /dev/null; then
    echo "Failed to create/update the agbot in the exchange"
    exit 1
  fi
}
echo "Checking for existing agbot, creating if none exists"
RESP=$(curl -s -o /dev/null -w %{http_code} -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $ICP_URL/ec-exchange/v1/orgs/IBM/agbots 2>/dev/null)
if [ $RESP == "404" ]; then
  # No agbots exist, let's add one
  echo "Creating the agbot '$EDGE_AGBOT_ID' in the exchange"
  create_agbot
elif [ $RESP == "200" ]; then
  # Agbots exists, let's see what we have
  echo "An agbot exists, checking its identity"
  FULL_RESP=$(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $ICP_URL/ec-exchange/v1/orgs/IBM/agbots 2>/dev/null)
  if [ $(echo $FULL_RESP | jq .agbots | jq length) -gt 1 ]; then
    echo "There is more than one agbot in your exchange, please see the troubleshooting guide for more information"
    exit 1
  else
    # Just the one agbot, let's make sure it matches
    if [ $(echo $FULL_RESP | jq .agbots | jq -r keys[]) == "IBM/$EDGE_AGBOT_ID" ]; then
      echo "Agbot exists, ensuring it has the proper credentials"
      create_agbot
    else
      echo "An agbot already exists, but its name doesn't match what we'd expect, was this database used to install another instance of IBM Edge Computing for Devices?"
      exit 1
    fi
  fi
else
  echo "There was an issue gathering information about your agbots from the exchange, response code of '$RESP' was returned"
  exit 1
fi

# Create org
echo "Checking for existing org, creating if none exists"
if ! curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $ICP_URL/ec-exchange/v1/orgs/$CLUSTER_NAME  > /dev/null 2>&1; then
  echo "Creating the org '$CLUSTER_NAME' in the exchange"
  if ! curl -sSf -X POST -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" -H "Content-Type:application/json" \
      -d '{"label": "'$CLUSTER_NAME' org", "description": "Organization for '$CLUSTER_NAME'"}' $ICP_URL/ec-exchange/v1/orgs/$CLUSTER_NAME > /dev/null; then
    echo "Failed to create the org in the exchange"
    exit 1
  fi
else
  echo "Org '$CLUSTER_NAME' already exists in the exchange"
fi

# Serving patterns and business policies from our agbot
echo "Enabling our agbot to serve patterns and business policies"
CURL_ARGS="curl -sSf -w %{http_code} -X POST -H Content-Type:application/json -u root/root:$EDGE_EXCHANGE_ROOT_PASS"

for ORG_SOURCE in IBM $CLUSTER_NAME; do
  for ORG_DEST in IBM $CLUSTER_NAME; do
    if ! [[ $ORG_SOURCE == $CLUSTER_NAME && $ORG_DEST == IBM ]]; then
      if ! $CURL_ARGS -d '{"patternOrgid": "'$ORG_SOURCE'", "pattern": "*", "nodeOrgid": "'$ORG_DEST'"}' $ICP_URL/ec-exchange/v1/orgs/IBM/agbots/$EDGE_AGBOT_ID/patterns > /dev/null 2>&1; then
        RESP=$($CURL_ARGS -d '{"patternOrgid": "'$ORG_SOURCE'", "pattern": "*", "nodeOrgid": "'$ORG_DEST'"}' $ICP_URL/ec-exchange/v1/orgs/IBM/agbots/$EDGE_AGBOT_ID/patterns 2>/dev/null) || true
        if [ $RESP == "409" ]; then
          echo "Pattern setup for '$ORG_SOURCE->$ORG_DEST' already exists, continuing"
        else
          echo "Pattern setup for '$ORG_SOURCE->$ORG_DEST' on agbot '$EDGE_AGBOT_ID' failed with a '$RESP' response, please see troubleshooting documentation"
        fi
      fi
    fi

    if [[ $ORG_SOURCE == $ORG_DEST ]]; then
      if ! $CURL_ARGS -d '{"businessPolOrgid": "'$ORG_SOURCE'", "businessPol": "*", "nodeOrgid": "'$ORG_DEST'"}' $ICP_URL/ec-exchange/v1/orgs/IBM/agbots/$EDGE_AGBOT_ID/businesspols > /dev/null 2>&1; then
        RESP=$($CURL_ARGS -d '{"businessPolOrgid": "'$ORG_SOURCE'", "businessPol": "*", "nodeOrgid": "'$ORG_DEST'"}' $ICP_URL/ec-exchange/v1/orgs/IBM/agbots/$EDGE_AGBOT_ID/businesspols 2>/dev/null) || true
        if [ $RESP == "409" ]; then
          echo "Business policy setup for '$ORG_SOURCE' already exists, continuing"
        else
          echo "Business policy setup for '$ORG_SOURCE' on agbot '$EDGE_AGBOT_ID' failed with a '$RESP' response, please see troubleshooting documentation"
        fi
      fi
    fi
  done
done

# Verifying CSS due to slow mongo DB startup before printing final verification output
COUNT=0
echo "Verifying the Cloud Sync Service is available"
while [[ ! $(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $ICP_URL/ec-css/api/v1/health | jq -r .general.healthStatus) == "green"  && $COUNT -lt 20 ]]; do
  echo "Waiting 15s for the Cloud Sync Service to be available $COUNT/30 retries"
  COUNT=$((COUNT+1))
  if [ $COUNT != 20 ]; then
    sleep 15
  fi
done

# Did we timeout
if [[ $COUNT -eq 20 ]]; then
  echo "The Cloud Sync Service was unreachable after 5m, giving up. Please identify the issue with the $EDGE_RELEASE_NAME-css pod and re-run this script when resolved"
  exit 1
else
  echo "The Cloud Sync Service is up and running"
fi

# Helm tests
echo ""
helm test $EDGE_RELEASE_NAME --tls
$EDGE_KUBECTL logs $EDGE_RELEASE_NAME-service-verification

# Print an exit message
echo -e "\nThere is one more step to populate the environment with sample services, patterns, and business policies.

Visit https://www.ibm.com/support/knowledgecenter/SSFKVV_3.2.1/devices/installing/install.html#postconfig for detailed instructions.

Welcome to the edge!\n"
