#!/bin/bash
#
#################################################################
# Licensed Materials - Property of IBM
# (C) Copyright IBM Corp. 2018.  All Rights Reserved.
#
# US Government Users Restricted Rights - Use, duplication or
# disclosure restricted by GSA ADP Schedule Contract with
# IBM Corp.
#################################################################
#
# Run this script to re-execute the sequence
#
#
# Usage:
#     ./postUpgrade.sh [ -n <namespace> ] [-cleanup]
#

FORCE=0
NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
dir="$(cd $(dirname $0) && pwd)/../../.."
HELM3=""
COUCH=0
MIGRATE=1
CLEANUP=0

check_helm() {
  binary="$1"
  alias="$2"
  version="$3"
  flags="$4"

  if [ "X$binary" == "X" ]; then
     
     binary=$(which $alias)
     if [ "X$binary" == "X" ]; then
        
        binary=$(which helm )
     fi
  fi
  if [ "X$binary" == "X" ]; then
    echo "$alias is not set"
    exit 1
  fi

  vcheck=$($binary version $flags 2>/dev/null)
  if [ "X$vcheck" == "X" ]; then
    echo "$binary has incorrect version"
    echo "$binary version $flags"
    exit 1
  fi
  echo "$binary"
}

runSubcharts() {
  if [ ! -d $dir/charts ]; then
     echo "INFO: no $dir/charts: subchart execution is skipped"
     return
  fi
  rm -rf /tmp/install.$$
  mkdir /tmp/install.$$
  for dirp in $dir/charts/*
  do
    if [ ! -d $dirp ]; then
      continue
    fi
    chart="$(basename $dirp)"
    script="$dirp/ibm_cloud_pak/pak_extensions/post-upgrade/postUpgrade.sh"
    if [ ! -f "$script" ]; then
      continue
    fi
    mkdir -p /tmp/install.$$/$chart
    cp -r $dirp/ibm_cloud_pak /tmp/install.$$/$chart
  done
  for tar in $dir/charts/*.tgz
  do
    chart=$(basename $tar | sed -e 's/-[\.0-9]*.tgz//')
      if [ -d "$root/charts/$chart" ]; then
         continue
      fi
      if [ "X$chart" == "X*.tgz" ]; then
        continue
      fi
      mkdir -p /tmp/install.$$/$chart
      tar -C /tmp/install.$$ -xzf $tar $chart/ibm_cloud_pak 2>/dev/null
  done
  cd /tmp/install.$$
  SCRIPTS=()
  ERRORS=""
  COMPLETED=()
  for script in $(find . -name postUpgrade.sh)
  do
    script=$(echo "$script"|sed -e 's!^./!!')
    SCRIPTS+=($script)
    echo "INFO: Running postUpgrade.sh for ${script%%/*}"
    if [ $FORCE -eq 1 ]; then
      bash $script -start -force
    else
      bash $script -start
    fi
    rc=$?
    if [ $rc -ne 0 ]; then
      echo "ERROR: postUpgrade.sh for ${script%%/*} has failed"
      exit 1
    fi
  done

  STARTED=$(date +%s)
  while sleep 30
  do
    TODO=0
    for script in "${SCRIPTS[@]}"
    do
      if [[ " ${COMPLETED[@]} " =~ " ${script} " ]]; then
        continue
      fi
      bash $script -check
      rc=$?
      case $rc in
        0) echo "INFO: postUpgrade for ${script%%/*} has been completed"
           COMPLETED+=($script)
           ;;
        2)
           TODO=1
           echo "INFO: postUpgrade for ${script%%/*} is still running"
           ;;
        *)
           ERRORS="$ERRORS ${script%%/*}"
           COMPLETED+=($script)
           echo "ERROR: postUpgrade for ${script%%/*} has been failed"
       esac
    done
    if [ $TODO -eq 0 ]; then
       break
    fi
    NOW=$(date +%s)
    DIFF=$(($NOW - $STARTED))
    if [ $DIFF -gt 900 ]; then
        echo "ERROR: Timeout waiting for upgrade to complete"
        exit 1
    fi
  done
  rm -rf /tmp/install.$$
  if [ "X$ERRORS" != "X" ]; then
    echo "ERROR: upgrade failed for charts: $ERRORS"
    exit 1
  fi
}

set_namespace() {
  NAMESPACE="$1"
  ns=$(kubectl get namespace $NAMESPACE -o name 2>/dev/null)
  if [ "X$ns" == "X" ]; then
    echo "ERROR: Invalid namespace $NAMESPACE"
    exit 1
  fi
  oc project $NAMESPACE
  if [ $? -ne 0 ]; then
    echo "ERROR: $NAMESPACE was not set"
    exit 1
  fi
}

scale_up() {

  local cs_namespace='ibm-common-services'
  cs_replicas=$(kubectl get deploy --no-headers -n $cs_namespace |\
      grep -E "catalog-ui|system-healthcheck-service" | awk '{print $1}')
  for replica in ${cs_replicas[@]}; do
      echo "INFO: Scaling Deployment $replica: 1 Replica"
      kubectl scale deploy "$replica" -n "$cs_namespace" --replicas=1
  done

}

migrate_couch() {

  migration_status=$(kubectl get configmap couch-migration -o jsonpath="{.data.status}" 2>/dev/null)

  #Check if the migration of the Couch Data is successful and if so dont repeat the migration
  if [ "X$migration_status" != "Xsuccess" ]; then
    
     echo "INFO: starting the CouchDB Migration"
     kubectl exec cp4s-toolbox /opt/bin/migrate_couch.sh
     
     #Get the latest status of the migration
     migration_status=$(kubectl get configmap couch-migration -o jsonpath="{.data.status}" 2>/dev/null)

     #if the Migration was successfull we can run the post-restore.sh to restart sequences.
     if [ "X$migration_status" == "Xsuccess" ]; then
           echo "INFO: Starting the post Couch Migration procedure"
           kubectl exec cp4s-toolbox /opt/bin/post-restore.sh
     fi
     
  else
     echo "INFO: Couch migration process has already succeeded, skipping."
  fi
}

delete_old_data() {
  # Delete unused secrets
  
  echo "INFO: Deleting unused secrets"
  
  # delete migration jobs
  for job in $(kubectl get job -o name 2>/dev/null | grep -e '-migration')
  do
     jn="${job##*/}"
     kubectl delete $job
     kubectl delete pod -ljob-name=$jn 2>/dev/null
  done
  
  helm3 delete ibm-dba-ek-isc-cases-elastic 2>/dev/null
  kubectl delete deploy -lchart=ibm-dba-ek
  kubectl delete sa ibm-dba-ek-isc-cases-elastic-bai-psp-sa --ignore-not-found=true
  kubectl delete secret -lapp.kubernetes.io/instance=isc-cases-elastic
  kubectl delete pvc -lchart=ibm-dba-ek --wait=false

}

reenable() {
  return
}


while true
do
  arg="$1"
  if [ "X$arg" == "X" ]; then
    break
  fi
  shift
  case "$arg" in
  -n)
    set_namespace "$1"
    shift
    ;;
  -helm3)
    HELM3="$1"
    shift
    ;;
  -helm2)
    shift
    ;;
  -cleanup)
    CLEANUP=1
    COUCH=0
    MIGRATE=0
    ;;
  -force)
    FORCE=1
    ;;
  -migrate)
    MIGRATE=1
    COUCH=0
    CLEANUP=0
    ;;
  -couch)
    MIGRATE=0
    COUCH=1
    CLEANUP=0
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    echo "Usage: $0 [ -n <Namespace> ] [-force] [-cleanup] [-couch] [-migrate]"
    exit 1
    ;;
esac
done

if [ "X$(which kubectl)" == "X" ]; then
  echo "ERROR: kubectl should be in the PATH: $PATH"
  exit 1
fi

HELM3=$(check_helm "$HELM3" "helm3" 'Version:"v3.2') 

echo "INFO: Initiating Post-Upgrade Steps"

if [ $COUCH -eq 1 ]; then
  migrate_couch
fi

#Scale up the deployments and statefulsets post-upgrade
if [ $MIGRATE -eq 1 ]; then
  scale_up
  runSubcharts
  reenable
fi
# Remove all old data no longer required post-upgrade
if [ $CLEANUP -eq 1 ]; then
  delete_old_data
fi  
