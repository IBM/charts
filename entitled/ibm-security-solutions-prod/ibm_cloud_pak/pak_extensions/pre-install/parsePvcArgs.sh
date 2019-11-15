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
#

usage() {
  if [ -n "$arg" -a "$arg" != "--help" ]; then
    echo "Invalid arg: $arg"
  fi
  echo "Usage: $0 ([ <option> <value> ])*"
  echo "  Where valid options are"
  echo "  --instance: name of instance to create, e.g. default"
  echo "  --storageSize: storage size e.g. 1Gi"
  echo "  --storageClass: storage class e.g. nfs-client"
  echo "  --replicas: number of replicas to create PVC for e.g. 3"
  echo "  --namespace: namespace to create PVC in e.g. isc"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    arg=$1
    case $arg in
      --help)
        usage; exit 0;;
      --instance)
        INSTANCE="$2"; shift; shift;;
      --storageSize)
        STORAGE="$2"; shift; shift;;
      --storageClass)
        STORAGECLASS="$2"; shift; shift;;
      --namespace)
        NAMESPACE="$2"; shift; shift;;
      --replicas)
        REPLICAS="$2"; shift; shift;;
      *)
        usage; exit 1;;
    esac
  done

  arg=
  # assert only for storageClass and namespace as some scripts don't require other args
  if [ -z "$STORAGECLASS" -o -z "$NAMESPACE" ]; then
    usage
    exit 1
  fi
}

