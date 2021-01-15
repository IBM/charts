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
# This script takes two arguments;
#   - short name of CRD, e.g. redis
#   - name of custem resource
#
# Example:
#     ./runcr.sh couchdb default
#

usage() {
echo "Usage $0 <CRD> <CR>"
exit 1
}

CRD="$1"
if [ "X$CRD" == "X" ]; then
 usage
fi

case $CRD in
  minio|etcd|elastic|appentitlements|offering|rabbitmq)
    ;;
  *)
  echo "Invalid CRD: $CRD"
  echo "Valid values are: minio|etcd|elastic|appentitlements|offering|rabbitmq"
  exit 1
esac

CR="$2"
if [ "X$CR" == "X" ]; then
  usage
fi

res=$(kubectl get $CRD $CR -o name 2>/dev/null)
if [ "X$res" == "X" ]; then
  echo "Resource $CR not found for type $CRD"
  exit 1
fi

kubectl patch $res --type merge --patch '{"spec":{"uuid":"'$(date +%s)'"}}'
echo "Updated $res"
