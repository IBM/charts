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
#     ./checkcr.sh cp4s [-all]
#

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
        XSuccessful)
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
}

NAMESPACE="$1"
if [ "X$NAMESPACE" == "X" ]; then
   echo "Usage: $0 <Namespace> [--all]"
   exit 1
fi

ALL=0
if [ "X$2" == "X--all" ]; then
  ALL=1
fi

checkSeq
for crd in couchdb redis etcd minio iscopenwhisk elastic cases
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
  echo "Problems in deployments:" 
  echo "$pods"
fi

pods=$(kubectl get statefulset -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name} {.status.replicas} {.status.readyReplicas}{"\n"}' | awk '{ if ($2 != $3) print $1 ": expect " $2 " pods, but have " $3 }')
if [ "X$pods" != "X" ]; then
  echo "Problems in statefulsets:" 
  echo "$pods"
fi

pvc=$(kubectl get pvc -n $NAMESPACE -o jsonpath='{range .items[*]}{.metadata.name} {.status.phase}{"\n"}' | awk '{ if ($2 != "Bound") print $1, $2 }')
if [ "X$pvc" != "X" ]; then
  echo "Problems in PVC:"
  echo "$pvc"
fi
    
