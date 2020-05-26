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
# This script takes one argument; sequence name
#
# Example:
#     ./rerunJob.sh <JOB>
#

run_job() {
  jobname="$1"
  job=$(kubectl get job $jobname -o name)
  if [ "X$job" == "X" ]; then
    echo "ERROR: job $jobname not found"
    exit 1
  fi
  res=$(kubectl get $job -o yaml |\
    grep -vE '^  (creationTimestamp|resourceVersion|selfLink|uid):' |\
    grep -vE '^  (selector|  matchLabels|    controller-uid):' |\
    grep -vE '^        controller-uid:' |\
    sed '/^status:/,$d')
  kubectl delete $job
  kubectl delete pod -ljob-name=$jobname
  echo "$res" | kubectl create -f -
}

arg="$1"
case "X$arg" in
  X)
    echo "Usage $0 JOBNAME"
    exit 1
    ;;
  *)
    run_job "$arg"
    ;;
esac
