#!/bin/bash
set -e

# Install the IBM Edge Application Manager chart, there are three levels of arguments
# NOTE: If you use a method supplying override arguments, you -must- set the global.image.repository value or image pulls will fail
#
### No arguments; uses local cluster as global.image.repository and the defaults in values.yaml
# ./ieam-install.sh
#
### One argument; a path to a separate yaml which overrides the main chart values.yaml for matching values
# ./ieam-install.sh ../relative/or/full/path/to/overrides.yaml
#
### Two arguments; The first a path to a separate yaml for overriding defaults, the second for specific overrides after that
# ./ieam-install.sh /path/to/file.yaml exchange.replicaCount=3
#

trap "echo -e '\nInstallation exited prematurely ... use the output above to identify the issue and then re-run the installation\n' && exit 1" ERR

echo "
By continuing you accept the terms and conditions of the IBM license stored in the LICENSES directory at the root of this chart, continue? [y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi

# Script prerequisites
PREREQUISITES=( docker jq make oc helm )
# Checking prerequisites
function check_prereqs(){
  echo "Checking local installation environment prerequisites..."
  for i in "${PREREQUISITES[@]}"; do
    if ! command -v ${i} >/dev/null 2>&1; then
      echo "'${i}' not found. Please install this prerequisite, exiting ..."
      exit 1
    fi
  done
  echo " confirmed."
}
check_prereqs

function die() {
    echo "$@" 1>&2
    exit 99
}

# Define our needed ENV vars
export EDGE_RELEASE_NAME=ibm-edge
EDGE_NAMESPACE=kube-system  #Deploying to kube-system namespace to integrate the edge UI
EDGE_OC="oc --namespace $EDGE_NAMESPACE"
EDGE_DISK_ROOT=/mnt/disk/$EDGE_RELEASE_NAME
args=("$@")
SCRIPT_LOCATION=$(dirname "$0")
DEFAULT_VALUES_FILE="${SCRIPT_LOCATION}/../../../values.yaml"
CHART_OVERRIDE_VALS=''
CHART_VAL=''
CLUSTER_NAME=$(oc get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_name}")
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

#################################################
# This function will Parse a simple YAML file
# and will output bash variables
# Based on: https://gist.github.com/pkuczynski/8665367
# Typical Usage:
# eval $(YamlParse__parse sample.yml "PREFIX_")
#
# @param $1: The yaml file to parse
# @param $2: The prefix to append to all of the
#       variables to be created
#################################################
function YamlParse__parse() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\):|\1|" \
        -e "s|^\($s\)\($w\)$s:$s[\"']\(.*\)[\"']$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

#################################################
# This function checks for a YAML value that is set in 3 
# different areas:
# 1. Via a set CLI option
# 2. Via an overridden values.yaml file
# 3. Via the default values.yaml file
#
# @param $1: Array of command line args. 
#               args[0]: override values.yaml
#               args[1]: any values manually set
# @param $2: Helm Chart key (i.e. global.databaseHA or 
#               agbotdb.persistence.storageClassName)
#
# see: 
#   Usage: ./ieam-install.sh [/optional/path/to/override/values.yaml] [optional.comma=separated,helm=values]
#################################################
function GetChartValue() {
  # Search Case 1
  # Find out if we've overridden the value in a command line argument
  unset CHART_VAL
  if [ $args ]; then
    searchKey=$2
    # we know we have args, but we don't know if we have 1 or 2 since they're both optional. However, if we find the key 
    # in any of the args, then we know we have override 'set' values.
    for i in "${args[@]}"; do
      if [[ $i =~ $searchKey ]]; then
        IFS=','; overrideVals=($i); unset IFS;
        for i in "${overrideVals[@]}"; do 
          if [[ $overrideVals[$i] =~ $searchKey ]]; then
            CHART_VAL=$(echo $i | cut -d '=' -f 2) #snip everything after the '=' to get the value we're after
            return 0
          fi
        done
      fi
    done
    # Search Case 2
    # Find out if we have specified our K/V in an override values.yaml file
    eval $(YamlParse__parse "${args[0]}" "HelmChart_")
    chartKey="HelmChart_${searchKey//./_}"
    CHART_VAL="${!chartKey}"
  else 
    searchKey=$1
  fi

  # Search Case 3
  # Find out if the K/V is specified in the default values.yaml file
  if [[ ! $CHART_VAL ]]; then
    eval $(YamlParse__parse "$DEFAULT_VALUES_FILE" "HelmChart_")
    chartKey="HelmChart_${searchKey//./_}"
    CHART_VAL="${!chartKey}"
  fi
}

#################################################
# This function checks the Kubernetes cluster to
# see if it can provision storage using the provided
# StorageClass name or use Dynamic Provisioning if
# a default StorageClass exists in the cluster.
# Function will die if installation cannot continue.
#
# @param $1: Helm Chart storage class name
#################################################
function CheckPersistentStorage() {
  storageClassDef=$1
  GetChartValue $args $storageClassDef
  storageClassName=$CHART_VAL
  if [ "$storageClassName" ] && [ $storageClassName != 'null' ]; then 
    # we found a storage class name, now see if it exists in platform
    if ! $EDGE_OC get storageclass | grep $storageClassName  > /dev/null 2>&1; then
      die "Storage class '${storageClassName}' does not exist in cluster '$CLUSTER_NAME'. Installation will fail."
    else
      echo " storage class '${storageClassName}' was found. Continuing installation using this storage class"
    fi
  else
    # We did not set a storage class name, so we're assuming we are going to do dynamic provisioning. 
    #  need to see if default exists on platform
    if [[ ! $defaultStorageClass ]]; then
      die "Helm chart did not define a storage class and no default storage class exists in cluster '$CLUSTER_NAME'. Dynamic provisioning and installation will fail."
    else
      echo " using dynamic provisioning and default storage class."
    fi
  fi
}

echo -e "\nGathering some data about your cluster..."
# Determine if connected to a valid K8s/OpenShift cluster
MASTER=$(oc get -n kube-public configmap -o jsonpath="{.items[]..data.cluster_address}")
if [ -z $MASTER ]; then
  echo "Couldn't determine master node, are you connected to a cluster?"
  exit 1
fi

# Check to ensure the expected secret exists
if [ "$EDGE_DATABASE_CHOICE" == "remote" ]; then
  if ! $EDGE_OC get secret $EDGE_RELEASE_NAME-remote-dbs  > /dev/null 2>&1; then
    echo "Setting value 'localDBs.enabled=false', but secret '$EDGE_RELEASE_NAME-remote-dbs' is not defined"
    echo -e "You will find directions for creating the secret in the README.md at the root of this chart\n"
    exit 1
  fi
fi
echo " confirmed cluster configuration."

# Are we using local databases or remote ones?
echo -e "\nInspecting chart(s) for database configuration..."
GetChartValue $args "localDBs.enabled"
if [ -z $CHART_VAL ]; then
  echo "Couldn't determine how databases are being deployed, please set the boolean 'localDBs.enabled'"
  exit 1
elif [ "$CHART_VAL" == "true" ]; then
  EDGE_DATABASE_CHOICE="local"
else
  EDGE_DATABASE_CHOICE="remote"
fi
echo -e " Using ${EDGE_DATABASE_CHOICE} database option"

# If doing local DBs, are we doing HA Databases?
if [ "$EDGE_DATABASE_CHOICE" == "local" ]; then
  GetChartValue $args "global.databaseHA"
  databaseHA=$CHART_VAL
  if [ "$databaseHA" == "true" ]; then
    # Did we set HA without enough workers?
    # defaultStorageClass=$($EDGE_OC get storageclass | grep "(default)" | grep "(default)" | cut -f1 -d " ")
    nodeCount=$($EDGE_OC get nodes -l node-role.kubernetes.io/worker --no-headers | wc -l | xargs )
    
    if [[ $nodeCount -eq 0 ]]; then
      die "ERROR: no nodes were found that matched label -l node-role.kubernetes.io/worker"
    elif [[ $nodeCount -lt 3 ]]; then
      echo " Less than 3 worker nodes found. HA databases have been disabled."
      CHART_OVERRIDE_VALS='agbotdb.keeper.replicas=1,agbotdb.sentinel.replicas=1,agbotdb.proxy.replicas=1,exchangedb.keeper.replicas=1,exchangedb.sentinel.replicas=1,exchangedb.proxy.replicas=1,cssdb.replicas=1'
    else 
      echo " HA databases option enabled"
    fi
  else
    echo " HA databases option disabled"
    CHART_OVERRIDE_VALS='agbotdb.keeper.replicas=1,agbotdb.sentinel.replicas=1,agbotdb.proxy.replicas=1,exchangedb.keeper.replicas=1,exchangedb.sentinel.replicas=1,exchangedb.proxy.replicas=1,cssdb.replicas=1'
  fi
else 
  # We're doing remote DBs. Check to ensure the expected secret exists
  if [ "$EDGE_DATABASE_CHOICE" == "remote" ]; then
    if ! $EDGE_OC get secret $EDGE_RELEASE_NAME-remote-dbs  > /dev/null 2>&1; then
      echo "Setting value 'localDBs.enabled=false', but secret '$EDGE_RELEASE_NAME-remote-dbs' is not defined"
      echo -e "You will find directions for creating the secret in the README.md at the root of this chart\n"
      exit 1
    fi
  fi
fi

# Check that default StorageClass exists if chart does not specify one
echo -e "\nInspecting chart(s) for persistent storage configuration..."
defaultStorageClass=$($EDGE_OC get storageclass | grep "(default)" | cut -f1 -d " ")
if ! [ $defaultStorageClass ]; then
  echo " No default StorageClass defined"
else
  echo " Default StorageClass is '${defaultStorageClass}'"
fi
echo "Checking AgBotDB Persistence"
CheckPersistentStorage "agbotdb.persistence.storageClassName"
echo "Checking ExchangeDB Persistence"
CheckPersistentStorage "exchangedb.persistence.storageClassName"
echo "Checking CSS DB Persistence"
CheckPersistentStorage "cssdb.persistentVolume.storageClass" 
echo -e "\nCluster and installation options verified."

# Prompt user for confirmation
echo -e "\nYou will be deploying the IBM Edge Application Manager to the cluster '$CLUSTER_NAME', continue? [y/N]:"
read RESPONSE
if [ ! "$RESPONSE" == 'y' ]; then
  echo "Exiting at users request"
  exit
fi

MANAGEMENT_URL="https://$(oc -n kube-public get cm ibmcloud-cluster-info -o jsonpath='{.data.cluster_ca_domain}'):$(oc -n kube-public get cm ibmcloud-cluster-info -o jsonpath='{.data.cluster_router_https_port}')"
EXCHANGE_URL="${MANAGEMENT_URL}/edge-exchange/v1"
CSS_URL="${MANAGEMENT_URL}/edge-css"

# Ensure we're only adding the role definitions if using localDBs -and- we're pointing to the internal registry
GetChartValue $args "localDBs.enabled"
LOCAL_DB=$CHART_VAL
GetChartValue $args "global.image.repository"
IMAGE_REGISTRY=$CHART_VAL
if [[ ("$IMAGE_REGISTRY" == "image-registry.openshift-image-registry.svc:5000/ibmcom") ]]; then
  # Add the image-puller role for the IEAM service account.
  oc policy add-role-to-user system:image-puller system:serviceaccount:kube-system:$EDGE_RELEASE_NAME-application-manager --namespace=ibmcom
  
  if [[ ("$LOCAL_DB" == "true") ]]; then
    # This binding will only be used if pulling images from the local image registry
    echo -e "\nCreating/updating database service account policy role binding for internal registry pulls," \
    "\n'not found' warning's are expected if this is an initial install as the service account doesn't exist yet\n"
    for DB_SA in agbot exchange css; do
      oc policy add-role-to-user system:image-puller system:serviceaccount:kube-system:$EDGE_RELEASE_NAME-${DB_SA}db --namespace=ibmcom
    done
  fi
  echo ""
fi

SETVALS=''
if [[ -n $CHART_OVERRIDE_VALS ]]; then
  SETVALS="--set $CHART_OVERRIDE_VALS"
fi
if [[ -z $1 ]]; then
  helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "$SETVALS"
else
  if [[ -z $2 ]]; then
    helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "-f $1 $SETVALS"
  else
    if [[ $SETVALS == '' ]]; then
      SETVALS="--set $2"
    else
      SETVALS="${SETVALS},$2"
    fi
    helm_install "$EDGE_RELEASE_NAME" "$SCRIPT_LOCATION/../../../" "-f $1 $SETVALS"
  fi
fi

# Trust the CA for the remaining REST calls
export CURL_CA_BUNDLE=/tmp/ca.crt
$EDGE_OC get secret cluster-ca-cert -o jsonpath="{.data['tls\.crt']}" | base64 --decode > $CURL_CA_BUNDLE

# Before we check our new pods, lets clean up any old helm tests, failed or not
if $EDGE_OC get pod $EDGE_RELEASE_NAME-service-verification > /dev/null 2>&1; then
  $EDGE_OC delete pod $EDGE_RELEASE_NAME-service-verification
fi

if $EDGE_OC get pods | grep $EDGE_RELEASE_NAME | grep test | awk '{print $1}' > /dev/null 2>&1; then
    for test in $($EDGE_OC get pods | grep $EDGE_RELEASE_NAME | grep test | awk '{print $1}'); do
    $EDGE_OC delete pod $test
  done
fi


# Ensure all the Deployments complete successfully
COUNT=0
if $(helm get values $EDGE_RELEASE_NAME -a --output json --tls | jq -r '.localDBs.enabled'); then
  EDGE_DEPLOYMENTS=(agbot agbotdb-proxy agbotdb-sentinel css exchange exchangedb-proxy exchangedb-sentinel ui)
  EDGE_STATEFULSETS=(agbotdb-keeper cssdb-server exchangedb-keeper)
else
  EDGE_DEPLOYMENTS=(agbot css exchange ui)
fi

while [[ $COUNT -lt 60 ]]; do
  ROLLOUT_STATUS="COMPLETE"
  for name in ${EDGE_DEPLOYMENTS[@]}; do
    FAILED=$(eval $EDGE_OC rollout status deployment $EDGE_RELEASE_NAME-$name --watch=false 2>&1 || true)
    if [[ $FAILED =~ "Waiting for" ]]; then
      echo -e "Deployment '$EDGE_RELEASE_NAME-$name' rollout still in progress..."
      ROLLOUT_STATUS="INCOMPLETE"
    elif [[ $FAILED =~ "error:" ]]; then
      echo -e "Error rolling out Deployment '$EDGE_RELEASE_NAME-$name'.\n  Message: '$FAILED'"
      exit 1
    else
      continue
    fi
  done

  for name in ${EDGE_STATEFULSETS[@]}; do
    FAILED=$(eval $EDGE_OC rollout status statefulset $EDGE_RELEASE_NAME-$name --watch=false 2>&1 || true)
    if [[ $FAILED =~ "Waiting for" ]]; then
      echo -e "Statefulset '$EDGE_RELEASE_NAME-$name' rollout still in progress..."
      ROLLOUT_STATUS="INCOMPLETE"
    elif [[ $FAILED =~ "error:" ]]; then
      echo -e "Error rolling out Statefulset '$EDGE_RELEASE_NAME-$name'.\n  Message: '$FAILED'"
      exit 1
    else
      continue
    fi
  done

  if [ $ROLLOUT_STATUS == "COMPLETE" ]; then
    break
  else
    echo -e "\nWaiting 15s for all Deployment and Statefulset rollouts to complete $COUNT/60 retries"
    COUNT=$((COUNT+1))
    if [ $COUNT != 60 ]; then
      sleep 15
    fi
  fi
done  

# Did we timeout
if [[ $COUNT -eq 60 ]]; then
  echo "The Deployments or Statefulsets above are still incomplete, giving up. Please identify the issue with the $EDGE_RELEASE_NAME deployments and re-run this script when resolved."
  exit 1
fi

COUNT=0
if $(helm get values $EDGE_RELEASE_NAME -a --output json --tls | jq -r '.localDBs.enabled'); then
  # Verify all Statefulsets rolled out
  echo -e "\nVerifying Statefulsets rollout status..."
  EDGE_STATEFULSETS=(agbotdb-keeper cssdb-server exchangedb-keeper)
  for name in ${EDGE_STATEFULSETS[@]}; do
    FAILED=$($EDGE_OC rollout status statefulset $EDGE_RELEASE_NAME-$name --watch=false 2>&1 || true)
    if [[ ($FAILED =~ "Waiting for") ]]; then
      echo -e "Error rolling out statefulset '$EDGE_RELEASE_NAME-$name'.\n Message: '$FAILED'"
      COUNT=$((COUNT+1))
    fi
  done
  echo "Complete."
  # Verify all Jobs completed successfully
  echo -e "\nVerifying Job completion status..."
  EDGE_JOBS=(agbotdb-create-cluster agbotdb-creds-gen cssdb-creds-gen exchangedb-create-cluster exchangedb-creds-gen)
  for name in ${EDGE_JOBS[@]}; do
    POD_STATUS=$($EDGE_OC describe job $EDGE_RELEASE_NAME-$name > /dev/null 2>&1 || true)
    # Jobs are cleaned up eventually after an installation. If we're rerunning the install on an existing cluster, we may not have jobs to check.
    if [[ "$POD_STATUS" =~ "Pods Statuses" ]]; then
      FAILED_PODS=$POD_STATUS | grep "Pods Statuses" | cut -d "/" -f 3 | sed -e 's/^[[:space:]]*//'
      if [ "$FAILED_PODS" != "0 Failed" ]; then
        echo "Job '$EDGE_RELEASE_NAME-$name' did not complete successfully"
        COUNT=$((COUNT+1))
      fi
    fi
  done
  echo "Complete."
fi

if [[ $COUNT > 0 ]]; then
  die "Helm deployment failed. Please investigate the issues above and retry the installation."
fi

# Check if root account is disabled. If so, skip verification tests
ROOT_ENABLED=$($EDGE_OC get cm ${EDGE_RELEASE_NAME}-config -o jsonpath="{.data.exchange-config}" | jq -r .api.root.enabled)
MAINTENANCE_MODE=$(helm get values $EDGE_RELEASE_NAME -a --output json --tls | jq -r '.global.maintenanceMode')
if [[ ("$ROOT_ENABLED" == "true") && ("$MAINTENANCE_MODE" == "false") ]]; then
  # Pull generated secrets into env variables
  export EDGE_AGBOT_TOKEN=$($EDGE_OC get secret ${EDGE_RELEASE_NAME}-auth -o jsonpath="{.data.agbot-token}" | base64 --decode) \
  EDGE_EXCHANGE_ROOT_PASS=$($EDGE_OC get secret ${EDGE_RELEASE_NAME}-auth -o jsonpath="{.data.exchange-root-pass}" | base64 --decode)

  # Wait for the exchange to come online
  COUNT=0
  echo "Verifying the Exchange API is available $COUNT/20 retries"
  while [[ $(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $EXCHANGE_URL/admin/status | jq -r .msg) != "Exchange server operating normally" && $COUNT -lt 20 ]]; do
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
        -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" \
        -d '{ "name": "'$EDGE_AGBOT_ID'", "token": "'$EDGE_AGBOT_TOKEN'", "publicKey": "", "msgEndPoint": ""}' \
        $EXCHANGE_URL/orgs/IBM/agbots/$EDGE_AGBOT_ID > /dev/null; then
      echo "Failed to create/update the agbot in the exchange"
      exit 1
    fi
  }
  echo "Checking for existing agbot, creating if none exists"
  RESP=$(curl -s -o /dev/null -w %{http_code} -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $EXCHANGE_URL/orgs/IBM/agbots 2>/dev/null)
  if [ $RESP == "404" ]; then
    # No agbots exist, let's add one
    echo "Creating the agbot '$EDGE_AGBOT_ID' in the exchange"
    create_agbot
  elif [ $RESP == "200" ]; then
    # Agbots exists, let's see what we have
    echo "An agbot exists, checking its identity"
    FULL_RESP=$(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $EXCHANGE_URL/orgs/IBM/agbots 2>/dev/null)
    if [ $(echo $FULL_RESP | jq .agbots | jq length) -gt 1 ]; then
      echo "There is more than one agbot in your exchange, please see the troubleshooting guide for more information"
      exit 1
    else
      # Just the one agbot, let's make sure it matches
      if [ $(echo $FULL_RESP | jq .agbots | jq -r keys[]) == "IBM/$EDGE_AGBOT_ID" ]; then
        echo "Agbot exists, ensuring it has the proper credentials"
        create_agbot
      else
        echo "An agbot already exists, but its name doesn't match what we'd expect, was this database used to install another instance of IBM Edge Application Manager?"
        exit 1
      fi
    fi
  else
    echo "There was an issue gathering information about your agbots from the exchange, response code of '$RESP' was returned"
    exit 1
  fi

  # Create org
  echo "Checking for existing org, creating if none exists"
  if ! curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $EXCHANGE_URL/orgs/$CLUSTER_NAME  > /dev/null 2>&1; then
    echo "Creating the org '$CLUSTER_NAME' in the exchange"
    if ! curl -sSf -X POST -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" -H "Content-Type:application/json" \
        -d '{"label": "'$CLUSTER_NAME' org", "description": "Organization for '$CLUSTER_NAME'"}' $EXCHANGE_URL/orgs/$CLUSTER_NAME > /dev/null; then
      echo "Failed to create the org in the exchange"
      exit 1
    fi
  else
    echo "Org '$CLUSTER_NAME' already exists in the exchange"
  fi

  # Preload expected cloudctl admin user, as org admin ... random long password that is not recorded or ever used (API key auth will be used)
  echo "Checking for existing admin user, creating if doesn't exist"
  if ! curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $EXCHANGE_URL/orgs/$CLUSTER_NAME/users/admin  > /dev/null 2>&1; then
    echo "Preloading the admin user to the org '$CLUSTER_NAME' in the exchange"

    # Ensure Locale CTYPE is set to C
    export LC_CTYPE=C
    if ! curl -sSf -X POST -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" -H "Content-Type:application/json" \
        -d '{"password":"'$(tr -cd '[:alnum:]' < /dev/urandom | fold -w40 | head -n1)'", "admin":true, "email":"admin"}' $EXCHANGE_URL/orgs/$CLUSTER_NAME/users/admin > /dev/null 2>&1; then
      echo "Failed to preload the admin user"
      exit 1
    fi
  else
    echo "Org user 'admin' already exists in the exchange"
  fi

  # Serving patterns and business policies from our agbot
  echo "Enabling our agbot to serve patterns and business policies"
  CURL_ARGS="curl -sSf -w %{http_code} -X POST -H Content-Type:application/json -u root/root:$EDGE_EXCHANGE_ROOT_PASS"

  for ORG_SOURCE in IBM $CLUSTER_NAME; do
    for ORG_DEST in IBM $CLUSTER_NAME; do
      if ! [[ $ORG_SOURCE == $CLUSTER_NAME && $ORG_DEST == IBM ]]; then
        if ! $CURL_ARGS -d '{"patternOrgid": "'$ORG_SOURCE'", "pattern": "*", "nodeOrgid": "'$ORG_DEST'"}' $EXCHANGE_URL/orgs/IBM/agbots/$EDGE_AGBOT_ID/patterns > /dev/null 2>&1; then
          RESP=$($CURL_ARGS -d '{"patternOrgid": "'$ORG_SOURCE'", "pattern": "*", "nodeOrgid": "'$ORG_DEST'"}' $EXCHANGE_URL/orgs/IBM/agbots/$EDGE_AGBOT_ID/patterns 2>/dev/null) || true
          if [ $RESP == "409" ]; then
            echo "Pattern setup for '$ORG_SOURCE->$ORG_DEST' already exists, continuing"
          else
            echo "Pattern setup for '$ORG_SOURCE->$ORG_DEST' on agbot '$EDGE_AGBOT_ID' failed with a '$RESP' response, please see troubleshooting documentation"
          fi
        fi
      fi

      if [[ $ORG_SOURCE == $ORG_DEST ]]; then
        if ! $CURL_ARGS -d '{"businessPolOrgid": "'$ORG_SOURCE'", "businessPol": "*", "nodeOrgid": "'$ORG_DEST'"}' $EXCHANGE_URL/orgs/IBM/agbots/$EDGE_AGBOT_ID/businesspols > /dev/null 2>&1; then
          RESP=$($CURL_ARGS -d '{"businessPolOrgid": "'$ORG_SOURCE'", "businessPol": "*", "nodeOrgid": "'$ORG_DEST'"}' $EXCHANGE_URL/orgs/IBM/agbots/$EDGE_AGBOT_ID/businesspols 2>/dev/null) || true
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
  while [[ ! $(curl -sSf -u "root/root:$EDGE_EXCHANGE_ROOT_PASS" $CSS_URL/api/v1/health | jq -r .general.healthStatus) == "green"  && $COUNT -lt 20 ]]; do
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
  $EDGE_OC logs $EDGE_RELEASE_NAME-service-verification

  # One last verification of Deployments rolled out
  echo -e "\nFinal verification of Deployments rollout status..."
  COUNT=0
  for name in ${EDGE_DEPLOYMENTS[@]}; do 
    FAILED=$($EDGE_OC rollout status deployment $EDGE_RELEASE_NAME-$name --watch=false 2>&1 || true)
    if [[ ($FAILED =~ "Waiting for") || ($FAILED =~ "error: deployment") ]] ; then 
      echo -e "Error rolling out deployment '$EDGE_RELEASE_NAME-$name'.\n  Message: '$FAILED'"
      COUNT=1
    fi
  done
  if [[ $COUNT -eq 0 ]]; then
    echo "Complete."
  fi

  # Exit message(s)
  echo -e "\nThere is one final manual process to be done to populate the exchange with sample services, patterns, and business policies.\n"
  
  if [[ $COUNT > 0 ]]; then 
    echo -e "\nPlease note that one or more deployments have failed to rollout successfully. It is recommended that you investigate the issues above and retry the installation.\n"
  else 
    echo -e "\nVisit https://www.ibm.com/support/knowledgecenter/SSFKVV_4.1/hub/post_install.html for detailed instructions.\n" \
            "\nWelcome to the edge!\n"
  fi
else
  if [ "$ROOT_ENABLED" == "false" ]; then
    echo -e "\n-----" \
      "\nThe Exchange root user account is disabled." \
      "\nUnable to run IBM Edge Application Manager verification tests.\n-----\n" \
      "\nWelcome to the edge!\n"
  elif [ "$MAINTENANCE_MODE" == "true" ]; then
    echo -e "\n-----" \
      "\nIn maintenance mode, used for database maintenance." \
      "\nOnce maintenance is complete, set the value 'global.maintenenceMode=false' and re-run this installation." \
      "\n-----\n"
  else
    echo -e "\nUnknown state, ensure the following values are set to the expected booleans (default: true,false) and re-run the installation:" \
      "\n$EDGE_OC get cm ${EDGE_RELEASE_NAME}-config -o jsonpath=\"{.data.exchange-config}\" | jq -r .api.root.enabled" \
      "\nhelm get values $EDGE_RELEASE_NAME -a --output json --tls | jq -r '.global.maintenanceMode'\n"
  fi
fi
