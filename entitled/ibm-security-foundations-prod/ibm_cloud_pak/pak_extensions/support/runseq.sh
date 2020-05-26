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
#     ./runseq.sh <sequence>
#

run_sequence() {
NAME="$1"
# Strip type prefix if set
NAME=$(echo $NAME | sed -e 's!^.*/!!')

guard=$(kubectl get iscguard $NAME -o 'jsonpath={.spec.generation}' 2>/dev/null)
seq=$(kubectl get iscsequence $NAME -o 'jsonpath={.spec.labels.generation}' 2>/dev/null)

if [ "X$seq" == "X" ]; then
  echo "Sequence $NAME not found"
  echo "Valid sequences are:"
  kubectl get iscsequence
  exit 1
fi

if [ "X$guard" == "X$seq" ]; then
  echo "Updating completed sequence"
else
  echo "Sequence was not completed - updating anyway"
  echo "Sequence uuid: $seq"
  echo "Guard uuid: $seq"
fi

kubectl patch iscsequence $NAME --type merge --patch '{"spec":{"labels":{"generation":"'$(date +%s)'"}}}'

seq=$(kubectl get iscsequence $NAME -o 'jsonpath={.spec.labels.generation}' 2>/dev/null)
echo "Updated sequence uuid: $seq"
}

arg="$1"
case "X$arg" in
  X)
    echo "Usage $0 sequence"
    exit 1
    ;;
  X-all)
     for sequence in $(kubectl get iscsequence -o name)
     do
       run_sequence "$sequence"
     done
    ;;
  *)
    run_sequence "$arg"
    ;;
esac
