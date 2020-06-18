#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2020.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
#
# This script can be used to stop, start or restart Watson Assistant.
#
# It is provided as is.
#
# It should be run from a machine that has kubernetes access to your ICP4D environment.
# You should be logged into your CP4D cluster and be switched to the correct project / namespace.
#
# Usage: wactl.sh --action [stop | start | restart | fast_restart | clean] --release RELEASE [--cli kubectl | oc] [--include-ds]
#
#  --action     The accepted options are stop, start, restart, fast_restart, clean
#  --release    The helm release of the WA deployment you want to perform the action on 
#  --cli        The cli to use. You can specify kubectl or oc. The default is oc 
#  --include-ds The datasources will have the action performed on them. Redis will not be included as part of the restart action.
#
# Please note:
# start        wactl can only start Watson Assistant if wactl was used to stop Watson Assistant
# restart      will ensure there is at least one replica for each pod running at all times
# fast_restart Will bring down all the replicas at the same time causing a disruption to the service
# clean        will remove the annotation 'previous-replicas' from all objects including datastores.
#
#################################################################

set -o nounset
set +e
#set -x

RELEASE=
ACTION=
DESIRED=
DATE=
USER_CLI=
CLI=oc
SCALE_TIMEOUT_SECONDS=600s
INCLUDE_DATASOURCES=false
OCVERSION=
STORE_FOUND=

function die() {
  echo "$@" 1>&2

  exit 99
}

function showHelp() {
  echo "Usage wactl.sh --action [stop | start | restart | fast_restart | clean] --release RELEASE [--cli kubectl | oc] [--include-ds]"
  echo "Controls the specified helm release of Watson Assistant."
  echo ""
  echo "--action:  The accepted options are stop, start, restart, fast_restart and clean."
  echo "--release: The helm release of the WA deployment you want to perform the action on."
  echo "--cli:     The cli to use. You can specify kubectl or oc. The default is oc."
  echo "--include-ds  The datasources will have the action performed on them. Redis will not be included as part of the restart action."
  echo ""
  echo "start        wactl can only start Watson Assistant if wactl was used to stop Watson Assistant"
  echo "restart      Will ensure there is at least one replica for each pod running at all times"
  echo "fast_restart Will bring down all the replicas at the same time causing a disruption to the service"
  echo "clean        Will remove the annotation 'previous-replicas' from all objects (including datastores). Useful if the previous stop / start failed"
  echo ""
  echo "NOTE: When wactl stops a component, it stores how many replicas there were in an annotation within the deployment / statefulset."
  echo "      If you try to start assistant and the annotation doesn't exist in one of the deployments / statefulsets, the script will fail."
  echo "      For example if you stopped the components by scaling down all the replicas manually and didn't use wactl, the annotations won't exist."
  echo
}

######################
# Get OC Version
#
# Work out the OC version using the selected CLI
#   For oc we can use oc version
#   For kubectl we need to use kubectl version
#   These commands return completely different output
######################

function getVersion {
  if [ "$CLI" == "oc" ]; then
    # RC will be 0 for Openshift v3 and 1 for v4
    oc version | grep "openshift v3." >/dev/null 2>&1
    RC=$?
    if [ "$RC" == "0" ]; then
      echo "3"
    else
      echo "4"
    fi
  else
    # Kubernetes server minor version will be 11 for OpenShift v3 and 14 for OpenShift v14
    minor=$(kubectl version | grep "Server Version" | grep -o -E '[0-9]+' | sed -n 2p)
    if [ "$minor" == "11" ]; then
      echo "3"
    else
      echo "4"
    fi
  fi
}

######################
# CLEAN
#
# Remove the annotations from all the objects. 
#
# You might want to do this if the deployments/statefulsets are
# started but still have annotations.
######################

function clean {
  $CLI get deployments,statefulsets --no-headers -l release=$RELEASE |
  while read objectname junk; do
    DESIRED=$($CLI get $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
    if [ "$DESIRED" != "" ]; then
      #we did manage to get the number of replicas previously used... clean it
      echo ""
      echo "Cleaning $objectname"
      echo "  Deleting annotation"
      $CLI annotate $objectname previous-replicas-
    fi
  done
}

######################
# STOP 
#
# Scale all deployments to 0 replicas
#
# Write the number of current replicas to an annotation so 
# we can find out when starting again how many replicas to scale up to.
#
# The stopping sequence for components is:
#   UI
#   Store
#   Gateway
#   Deployments
#   Statefulsets
######################
function stop {
  #First, check we can't find the previous-replicas label in the objects.
  if ! $INCLUDE_DATASOURCES; then
    LABEL=",app.kubernetes.io/name!=store-postgres,app.kubernetes.io/name!=redis,app.kubernetes.io/name!=ibm-mongodb,app.kubernetes.io/name!=etcd3,app.kubernetes.io/name!=clu-minio"
  else
    LABEL=""
  fi
  echo "Checking we can't find the label 'previous-replicas' in all the deployments/statefulsets...."
  CONT=true
  while read objectname junk; do
    DESIRED=$($CLI get $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
    if [ "$DESIRED" != "" ]; then
      #we did manage to get the number of replicas previously used which probably means the deployment is already stopped ans we don't want to overwrite
      # the annotation with 0 replicas
      echo "ERROR: Found the annotation previous-replicas=$DESIRED in $objectname."
      CONT=false
    fi
  done <<< "$($CLI get deployment,statefulset --no-headers -l release=$RELEASE${LABEL})"

  if ! $CONT; then
    echo ""
    die "Failed to stop Watson Assistant as some deployments/statefulsets contained the label 'previous-replicas' which implies the pods are already stopped."
  fi

  # Stopping UI, then Store
  for COMPONENT in ui store; do
    $CLI get deployment --no-headers -l release=$RELEASE,component=$COMPONENT |
    while read objectname replicasdesired junk; do
      if [ "$OCVERSION" == "4" ]; then
        replicasdesired=$($CLI get deployment $objectname -o jsonpath='{.spec.replicas}')
      fi
      echo ""
      echo "Processing $objectname"
      echo "  Desired replicas = $replicasdesired"
      echo "  Adding annotation previous-replicas=$replicasdesired"
      $CLI annotate deployment $objectname previous-replicas=$replicasdesired --overwrite
      echo "  Scaling down to 0"
      $CLI scale deployment $objectname --replicas=0 --timeout=$SCALE_TIMEOUT_SECONDS
    done
  done

  # Stopping Gateway
  $CLI get deployment --no-headers -l release=$RELEASE,app.kubernetes.io/component=gateway |
  while read objectname replicasdesired junk; do
    if [ "$OCVERSION" == "4" ]; then
      replicasdesired=$($CLI get deployment $objectname -o jsonpath='{.spec.replicas}')
    fi
    echo ""
    echo "Processing $objectname"
    echo "  Desired replicas = $replicasdesired"
    echo "  Adding annotation previous-replicas=$replicasdesired"
    $CLI annotate deployment $objectname previous-replicas=$replicasdesired --overwrite
    echo "  Scaling down to 0"
    $CLI scale deployment $objectname --replicas=0 --timeout=$SCALE_TIMEOUT_SECONDS
  done

  # Stopping the rest of the deployments
  if ! $INCLUDE_DATASOURCES; then
    LABEL="component!=ui,component!=store,app.kubernetes.io/component!=gateway,component!=stolon-sentinel,component!=stolon-proxy"
  else
    LABEL="component!=ui,component!=store,app.kubernetes.io/component!=gateway"
  fi
  $CLI get deployment --no-headers -l release=$RELEASE,component!=ui,$LABEL |
  while read objectname replicasdesired junk; do
    if [ "$OCVERSION" == "4" ]; then
      replicasdesired=$($CLI get deployment $objectname -o jsonpath='{.spec.replicas}')
    fi
    echo ""
    echo "Processing $objectname"
    echo "  Desired replicas = $replicasdesired"
    echo "  Adding annotation previous-replicas=$replicasdesired"
    $CLI annotate deployment $objectname previous-replicas=$replicasdesired --overwrite
    echo "  Scaling down to 0"
    $CLI scale deployment $objectname --replicas=0 --timeout=$SCALE_TIMEOUT_SECONDS
  done

  # Stopping the statefulsets
  if $INCLUDE_DATASOURCES; then
    $CLI get statefulset --no-headers -l release=$RELEASE |
    while read objectname replicasdesired junk; do
      if [ "$OCVERSION" == "4" ]; then
        replicasdesired=$($CLI get statefulset $objectname -o jsonpath='{.spec.replicas}')
      fi
      echo ""
      echo "Processing $objectname"
      echo "  Desired replicas = $replicasdesired"
      echo "  Adding annotation previous-replicas=$replicasdesired"
      $CLI annotate statefulset $objectname previous-replicas=$replicasdesired --overwrite
      echo "  Scaling down to 0"
      $CLI scale statefulset $objectname --replicas=0 --timeout=$SCALE_TIMEOUT_SECONDS
    done
  fi
}

######################
# START
#
# Scale up all deployments to number of replicas found in
# the annotation created in the stop function and
# then delete the annotation.
#
# The starting sequence for components is:
#   All statefulsets (except postgres-store-keeper)
#   postgres-store-sentinel deployment
#   postgres-store-proxy deployment
#   postgres-store-keeper statefulset
#   All deployments (except gateway, ui, and store)
#   Gateway
#   Store
#   UI
######################
function start {
  #Scale up all deployments to number of replicas found in the annotation created in the stop function.
  #Then delete the annotation.

  #First, check we can find the previous-replicas label in all the objects.
  if ! $INCLUDE_DATASOURCES; then
    LABEL=",app.kubernetes.io/name!=store-postgres,app.kubernetes.io/name!=redis,app.kubernetes.io/name!=ibm-mongodb,app.kubernetes.io/name!=etcd3,app.kubernetes.io/name!=clu-minio"
  else
    LABEL=""
  fi
  echo "Checking we can find the label 'previous-replicas' in all the deployments/statefulsets...."
  CONT=true
  while read objectname junk; do
    DESIRED=$($CLI get $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
    if [ "$DESIRED" == "" ]; then
      #we didn't managed to get the number of replicas previously used
      echo ""
      echo "ERROR: Couldn't find annotation previous-replicas in $objectname. You can add the annotation using:"
      echo "$CLI annotate $objectname previous-replicas=ENTER_NUMBER_OF_REPLICAS"
      CONT=false
    fi
  done <<< "$($CLI get deployment,statefulset --no-headers -l release=$RELEASE${LABEL})"

  if ! $CONT; then
    echo ""
    die "Failed to start Watson Assistant as not all deployments/statefulsets contained the label 'previous-replicas' which implies either the pods are already running or weren't stopped by wactl"
  fi

  # Starting All statefulsets (except postgres-store-keeper)
  if $INCLUDE_DATASOURCES; then
    $CLI get statefulsets --no-headers -l release=$RELEASE,component!=stolon-keeper |
    while read objectname junk; do
      echo ""
      echo "Processing $objectname"
      DESIRED=$($CLI get statefulsets $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
      if [ "$DESIRED" == "" ]; then
        #we didn't managed to get the number of replicas previously used
        die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
      fi
      echo "  Desired replicas = $DESIRED"
      echo "  Scaling up to $DESIRED"
      # --current-replicas=0 ... means only perform the scale if the current replicas is 0
      #which means if the pod isn't stopped, we won't try to start it
      $CLI scale statefulsets $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
      echo "  Deleting annotation"
      $CLI annotate statefulsets $objectname previous-replicas-
    done

    # Starting postgres-store-sentinel, then postgres-store-proxy
    for COMPONENT in stolon-sentinel stolon-proxy; do
      $CLI get deployment --no-headers -l release=$RELEASE,component=$COMPONENT |
      while read objectname junk; do
        echo ""
        echo "Processing $objectname"
        DESIRED=$($CLI get deployment $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
        if [ "$DESIRED" == "" ]; then
          #we didn't managed to get the number of replicas previously used
          die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
        fi
        echo "  Desired replicas = $DESIRED"
        echo "  Scaling up to $DESIRED"
        # --current-replicas=0 ... means only perform the scale if the current replicas is 0
        #which means if the pod isn't stopped, we won't try to start it
        $CLI scale deployment $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
        echo "  Deleting annotation"
        $CLI annotate deployment $objectname previous-replicas-
      done
    done

    # Starting postgres-store-keeper statefulset
    $CLI get statefulsets --no-headers -l release=$RELEASE,component=stolon-keeper |
    while read objectname junk; do
      echo ""
      echo "Processing $objectname"
      DESIRED=$($CLI get statefulsets $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
      if [ "$DESIRED" == "" ]; then
        #we didn't managed to get the number of replicas previously used
        die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
      fi
      echo "  Desired replicas = $DESIRED"
      echo "  Scaling up to $DESIRED"
      # --current-replicas=0 ... means only perform the scale if the current replicas is 0
      #which means if the pod isn't stopped, we won't try to start it
      $CLI scale statefulsets $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
      echo "  Deleting annotation"
      $CLI annotate statefulsets $objectname previous-replicas-
    done
  fi

  # Starting all deployments (except postgres-store-sentinel, postgres-store-proxy, gateway, ui, and store)
  $CLI get deployment --no-headers -l release=$RELEASE,component!=stolon-sentinel,component!=stolon-proxy,component!=ui,component!=store,app.kubernetes.io/component!=gateway |
  while read objectname junk; do
    echo ""
    echo "Processing $objectname"
    DESIRED=$($CLI get deployment $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
    if [ "$DESIRED" == "" ]; then
      #we didn't managed to get the number of replicas previously used
      die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
    fi
    echo "  Desired replicas = $DESIRED"
    echo "  Scaling up to $DESIRED"
    # --current-replicas=0 ... means only perform the scale if the current replicas is 0
    #which means if the pod isn't stopped, we won't try to start it
    $CLI scale deployment $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
    echo "  Deleting annotation"
    $CLI annotate deployment $objectname previous-replicas-
  done

  # Starting Gateway
  $CLI get deployment --no-headers -l release=$RELEASE,app.kubernetes.io/component=gateway |
  while read objectname junk; do
    echo ""
    echo "Processing $objectname"
    DESIRED=$($CLI get deployment $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
    if [ "$DESIRED" == "" ]; then
      #we didn't managed to get the number of replicas previously used
      die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
    fi
    echo "  Desired replicas = $DESIRED"
    echo "  Scaling up to $DESIRED"
    # --current-replicas=0 ... means only perform the scale if the current replicas is 0
    #which means if the pod isn't stopped, we won't try to start it
    $CLI scale deployment $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
    echo "  Deleting annotation"
    $CLI annotate deployment $objectname previous-replicas-
  done

  # Starting Store, then UI
  for COMPONENT in store ui; do
    $CLI get deployment --no-headers -l release=$RELEASE,component=$COMPONENT |
    while read objectname junk; do
      echo ""
      echo "Processing $objectname"
      DESIRED=$($CLI get deployment $objectname -o jsonpath='{.metadata.annotations.previous-replicas}' || die "ERROR: Failed to query annotations on $objectname")
      if [ "$DESIRED" == "" ]; then
        #we didn't managed to get the number of replicas previously used
        die "ERROR: Couldn't find annotation previous-replicas in $objectname. This could be because it is already running or it wasn't stopped by wactl."
      fi
      echo "  Desired replicas = $DESIRED"
      echo "  Scaling up to $DESIRED"
      # --current-replicas=0 ... means only perform the scale if the current replicas is 0
      #which means if the pod isn't stopped, we won't try to start it
      $CLI scale deployment $objectname --current-replicas=0 --replicas=$DESIRED --timeout=$SCALE_TIMEOUT_SECONDS
      echo "  Deleting annotation"
      $CLI annotate deployment $objectname previous-replicas-
    done
  done
}

######################
# RESTART
# 
# kubectl rollout restart command is only available in k8s 1.15
#
# Instead we'll force a rolling restart by tweaking the objects with a patch command
#
# Redis will not be restarted even with the --include-ds flag (due to a known Redis issue i.e. Redis will fail to restart)
######################
function restart {
  echo "Performing non-disruptive restart by patching..."
  if ! $INCLUDE_DATASOURCES; then
    OBJECT_TYPE="deployment"
    GET_OBJECTS="deployment"
    LABEL=",component!=stolon-sentinel,component!=stolon-proxy"
  else
    OBJECT_TYPE=""
    GET_OBJECTS="deployment,statefulset"
    LABEL=",app.kubernetes.io/name!=redis"
  fi
  $CLI get $GET_OBJECTS --no-headers -l release=$RELEASE${LABEL} |
  while read objectname junk; do
    echo "Processing $objectname"
    DATE=$(date +'%s')
    echo "  patching using annotation restart-date=$DATE to force rolling restart"
    $CLI patch $OBJECT_TYPE $objectname -p "{\"spec\":{\"template\":{\"metadata\":{\"annotations\":{\"restart-date\":\"$DATE\"}}}}}"
    echo "  Deleting annotation"
    $CLI annotate $OBJECT_TYPE $objectname restart-date-
  done
}

######################
# FAST RESTART
#
# This approach will run a delete command for every pod at the same time
######################
function fast_restart {
  if ! $INCLUDE_DATASOURCES; then
    LABEL=",app.kubernetes.io/name!=store-postgres,app.kubernetes.io/name!=redis,app.kubernetes.io/name!=ibm-mongodb,app.kubernetes.io/name!=etcd3,app.kubernetes.io/name!=clu-minio"
  else
    LABEL=""
  fi
  echo "Performing fast (disruptive) restart by deleting all pods with the label release=$RELEASE"
  $CLI get pods --no-headers -l release=$RELEASE${LABEL} |
  while read objectname junk; do
    echo "Deleting pod $objectname"
    $CLI delete pod $objectname &
  done
}

#############################
# Processing command-line parameters
#############################
while (( $# > 0 )); do
  case "$1" in
    -r | --r | --release )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --release argument has no value"
      fi
      shift
      RELEASE="$1"
      ;;
    -a | --a | --action )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --action argument has no value"
      fi
      shift
      ACTION="$1"
      ;;
    -c | --c | --cli )
      option=${2:-}
      if [[ $option == -* ]] || [[ $option == "" ]]; then
        die "ERROR: --cli argument has no value"
      fi
      shift
      USER_CLI="$1"
      if [ "$USER_CLI" != "kubectl" ] && [ "$USER_CLI" != "oc" ]; then
        die "Error: You must specify kubectl or oc with the --cli arg."
      fi
      ;;
    --include-ds )
      INCLUDE_DATASOURCES=true
      shift
      ;;
    -h | --h | --help )
      showHelp
      exit 2
      ;;
    * | -* )
      echo "Unknown option: $1"
      echo ""
      showHelp
      exit 99
      ;;
  esac
  shift
done

if [ -z "$RELEASE" ]; then
  echo "**********************************************************"
  echo "Error: You must specify a helm release."
  echo "**********************************************************"
  echo ""
  showHelp
  exit 99
fi

if [ -z "$ACTION" ]; then
  echo "**********************************************************"
  echo "Error: You must specify an action."
  echo "**********************************************************"
  echo ""
  showHelp
  exit 99
fi

##################
# Checking for CLI
##################
if [ -z "$USER_CLI" ]; then
  # User didn't specify a CLI so try to use oc, then kubectl.
  if ! which oc >/dev/null; then
    echo "WARNING: oc command not found, checking for kubectl command..."
    echo ""
    if ! which kubectl >/dev/null; then
      die "ERROR: kubectl command not found. Ensure you have oc or kubectl installed and on your PATH."
    fi
    CLI=oc
  fi
else
  # User specified a CLI, check we can use it
  CLI=$USER_CLI
  if ! which $CLI >/dev/null; then
    die "ERROR: $CLI command not found. Ensure that you have $CLI installed and on your PATH."
  fi
fi

#################
# Test connection
#################
if [ "$CLI" == "oc" ]; then
  if ! oc whoami >/dev/null 2>&1 ; then
    die "ERROR: Can't connect to Cluster. Please log into your Cluster and switch to the correct project."
  fi
else
  if ! kubectl get deployments >/dev/null 2>&1 ; then
    die "ERROR: Can't connect to Cluster. Please log into your Cluster and switch to the correct namespace."
  fi
fi
 
TIMESTAMP=`date +%Y-%m-%d_%H-%M-%S`
echo "Dumping current state to ~/.wactl_state.$TIMESTAMP"
$CLI get deployment,statefulset -l release=$RELEASE >~/.wactl_state.$TIMESTAMP 2>&1
echo ""

################
# Get OC Version
################
OCVERSION=$(getVersion)

echo "Found OpenShift v${OCVERSION}"
echo ""

#############################
# Check we can find Assistant
# by searching for store pod
#############################
STORE_FOUND=$($CLI get deployment --no-headers -l release=$RELEASE,component=store --ignore-not-found=true | wc -l)

if [ "$STORE_FOUND" != "0" ]; then
  echo "Found Watson Assistant"
  echo ""
else
  die "Could not find Watson Assistant store deployment for helm release $RELEASE. Please check you specified the correct release."
fi

#################
# Perform Action 
#################
case "$ACTION" in
  stop )
    stop
    ;;
  start )
    start 
    ;;
  restart )
    restart 
    ;;
  fast_restart )
    fast_restart 
    ;;
  clean )
    clean 
    ;;
  * | -* )
    echo "ERROR: Unknown action - $ACTION"
    showHelp
    exit 99
    ;;
esac
