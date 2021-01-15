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
# Run this script to monitor custom resource processing
#
# This script takes one argument; namespace
#
# Example:
#     ./checkcr.sh [-n cp4s] [-all]
#

checkScale() {
  repl=$(kubectl get iscinventory iscplatform -o jsonpath="{.spec.definitions.replicas}")
  if [ "X$repl" == "X" ]; then
    echo "ERROR: no iscinventory found"
    return
  fi
  ar=$(kubectl get deploy authsvc -o jsonpath="{.spec.replicas}")
  case X${ar} in
    X$repl) ;;
    X)
       echo "ERROR: authsvc process not found"
       ;;
    *) echo "ERROR: invalid number of authsvc replicas: $ar"
       ;; 
  esac
  return
}

checkSeq() {
    for seq in $(kubectl get iscsequence -n $NAMESPACE -o name 2>/dev/null|sed -e 's!^.*/!!')
    do
      kubectl get iscsequence -n $NAMESPACE $seq -o yaml > /tmp/checkseq.$$.yaml
      gen=$(grep '    generation: ' /tmp/checkseq.$$.yaml | sed -e 's/^.*: //' -e 's/"//g')
      guard=$(kubectl get -n $NAMESPACE iscguard $seq -o 'jsonpath={.spec.generation}' 2>/dev/null)
      ar="$(sed -e '1,/ ansibleResult:/d' /tmp/checkseq.$$.yaml)"
      if [ "X$ar" == "X" ]; then
        ar="$(sed -e '1,/ conditions:/d' /tmp/checkseq.$$.yaml)"
      fi

      status=$(echo "$ar" | grep ' reason: ' | head -1 | sed -e 's/^.*: //')
      time=$(echo "$ar" | grep ' lastTransitionTime: ' | head -1 | sed -e 's/^.*: //')
      message=$(echo "$ar" | sed -e '1,/ lastTransitionTime: /d' -e 's/    message: //' |\
            sed  -n '1,/    reason:/p' | sed -e '$d' | head -10)

      if [ "X$gen" == "X$guard" ]; then
        if [ $ALL -eq 1 ]; then
            echo "ISCSequence $seq completed at $time"
        fi
        continue
      fi

      if [ "X$status" == "X" ]; then
        echo "ISCSequence $seq is in the queue"
        continue
      fi

      case "X$status" in
        X)
          echo "ISCSequence $seq is in the queue"
          continue
          ;;
        XRunning)
          echo "ISCSequence $seq is running since $time"
          continue
          ;;
        XSuccessful)
          echo "ISCSequence $seq is waiting to be upgraded"
          continue
          ;;
        *)
          echo "ISCSequence $seq has status $status at $time: $message"
          continue
          ;;
      esac
    done
    return
}

checkGoCR() {
  for cr in $(kubectl get $1 -o name 2>/dev/null)
  do
    ar=$(kubectl get $cr -o yaml | sed -e '1,/status:/d')
    status=$(echo "$ar" | grep type: | head -1 | sed -e 's/^.*: //')
    message=$(echo "$ar" | grep message: | head -1 | sed -e 's/^.*: //')
    time=$(echo "$ar" | grep lastTransitionTime: | head -1 | sed -e 's/^.*: //')

    case "X$status" in
       X) echo "$cr is not yet processed"
          ;;
       XCompleted|XSuccessful)
          if [ $ALL -eq 1 ]; then
            echo "$cr has been completed at $time"
          fi
          ;;
        *) echo "$cr has status "$status" since $time"
          ;;
     esac

  done
}

checkCR() {
    crd="$1"
    for cr in $(kubectl get $crd -n $NAMESPACE -o name 2>/dev/null)
    do
       kubectl get -n $NAMESPACE $cr -o yaml > /tmp/checkseq.$$.yaml
       ar="$(sed -e '1,/ ansibleResult:/d' /tmp/checkseq.$$.yaml)"
       if [ "X$ar" == "X" ]; then
         ar="$(sed -e '1,/ conditions:/d' /tmp/checkseq.$$.yaml)"
       fi
       status=$(echo "$ar" | grep ' reason: ' | head -1 | sed -e 's/^.*: //')
       time=$(echo "$ar" | grep ' lastTransitionTime: '  | head -1 | sed -e 's/^.*: //')
       message=$(echo "$ar" | sed -e '1,/ lastTransitionTime: /d' -e 's/    message: //' |\
            sed  -n '1,/    reason:/p' | sed -e '$d' | head -10)

      case "X$status" in
        X)
          echo "$cr is in the queue"
          continue
          ;;
        XRunning)
          echo "$cr is running since $time"
          continue
          ;;
        XSuccessful|XComplete|XCompleted|XCreateClientSuccessful)
          if [ $ALL -eq 1 ]; then
            echo "$cr has been completed at $time"
          fi
          continue
          ;;
        *)
          echo "$cr has status $status at $time: $message"
          continue
          ;;
      esac
    done
    return
}

checkKubeSystem() {
  csn=$(kubectl get namespace ibm-common-services -o name 2>/dev/null)
  if [ "X$csn" == "X" ]; then
    CS_NAMESPACE='kube-system'
    xtra="icp-management-ingress"
  else
    CS_NAMESPACE='ibm-common-services'
    xtra="management-ingress"
  fi
  pods=$(kubectl get pod -n $CS_NAMESPACE|grep -vE 'Running|Completed|NAME')
  if [ "X$pods" != "X" ]; then
    echo "ERROR: Some of kube-system pods are in failed state:"
    echo "$pods"
  fi

  # check if necessary components are installed
  for app in auth-idp auth-pap auth-idp helm  \
             platform-api $xtra \
             oidcclient-watcher secret-watcher
  do
     pod=$(kubectl get pod -o name -n $CS_NAMESPACE -lapp=$app)
     if [ "X$pod" == "X" ]; then
         echo "ERROR: Common services application $app not installed or failed"
     fi
  done
}

checkOIDC() {
  checkCR "Client"
  secret=$(kubectl get secret ibm-isc-oidc-credentials -o name)
  if [ "X$secret" == "X" ]; then
    echo "ERROR: secret ibm-isc-oidc-credentials has not been created"
  else
    if [ $ALL -eq 1 ]; then
       echo "INFO: secret ibm-isc-oidc-credentials has been created"
    fi
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
}

NAMESPACE=$(oc project | sed -e 's/^[^"]*"//' -e 's/".*$//')
ALL=0

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
  --all)
    ALL=1
    ;;
  *)
    echo "ERROR: Invalid argument $arg"
    echo "Usage: $0 [ -n <Namespace> ] [--all]"
    exit 1
    ;;
esac
done

checkScale
checkKubeSystem
checkOIDC

checkSeq

checkGoCR isctrusts.isc.ibm.com
for crd in etcds.isc.ibm.com minios.isc.ibm.com elastics.isc.ibm.com appentitlements cases.isc.ibm.com postgresqloperator.isc.ibm.com rabbitmq.isc.ibm.com
do 
  checkCR $crd
done
rm -f /tmp/checkseq.$$.yaml

# Check if there are pods in unexpected state
pods="$(kubectl get pod -n $NAMESPACE | tail -n +2 | grep -vE 'Running|Completed|Terminating')"

if [ "X$pods" != "X" ]; then
  echo "The following pods are in non-running state"
  echo "$pods"
fi

pods=$(kubectl get deploy -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name} {.status.replicas} {.status.readyReplicas}{"\n"}'| awk '{ if ($2 != $3) print $1 ": expect " $2 " pods have uptodate " $3 }')
if [ "X$pods" != "X" ]; then
  echo "Problems in deployments replicas:"
  echo "$pods"
fi

couchdbcluster=$(kubectl get statefulset -n $NAMESPACE -lformation_id=default-couchdbcluster -o name 2> /dev/null)
if [ "X$couchdbcluster" == "X" ]; then
   echo "Error: couchdbcluster not created for some reason"
fi

redis=$(kubectl get statefulset -n $NAMESPACE -lformation_id=default-redis -o name 2> /dev/null)
if [ "X$redis" == "X" ]; then
   echo "Error: redis instance not created for some reason"
fi

pods=$(kubectl get statefulset -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name} {.status.replicas} {.status.readyReplicas}{"\n"}' | awk '{ if ($2 != $3) print $1 ": expect " $2 " pods, but have " $3 }')
if [ "X$pods" != "X" ]; then
  echo "Problems in statefulsets replicas:"
  echo "$pods"
fi

pvc=$(kubectl get pvc -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name} {.status.phase}{"\n"}' | awk '{ if ($2 != "Bound") print $1, $2 }')
if [ "X$pvc" != "X" ]; then
  echo "Problems in PVC:"
  echo "$pvc"
fi
