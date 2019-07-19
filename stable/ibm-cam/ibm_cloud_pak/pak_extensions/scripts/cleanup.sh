#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016-2019 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
export tiller_version=$(docker images | grep icp | grep tiller | head -1 | awk '{print $2}' | sed 's|v||g')
export tiller_icp=$(echo $tiller_version | awk -F'[.]' '{print $3}' | awk -F'[-]' '{print $2}')

if [ "$1" != "services" ]; then
  if [ ! -z $tiller_icp ]; then
    echo helm del cam-$1 --purge --tls 
    helm del cam-$1 --purge --tls 
  else
    echo helm del cam-$1 --purge
    helm del cam-$1 --purge
  fi

  echo kubectl -n $1 delete -l release=cam-$1 job
  kubectl -n $1 delete -l release=cam-$1 job
  echo "Waiting for Pods to terminate"
  kubectl -n $1 get -l release=cam-$1 pod
  pods=$(kubectl -n $1 get -l release=cam-$1 pods | grep -)
  while [ "${pods}" ]; do
          sleep 2
          kubectl -n $1 get -l release=cam-$1 pod
          pods=$(kubectl -n $1 get -l release=cam-$1 pods | grep -)
  done
  echo "All pods terminated"

  echo kubectl delete -n $1 pvc cam-logs-pv
  kubectl delete -n $1 pvc cam-logs-pv

  echo kubectl delete -n $1 pvc cam-mongo-pv
  kubectl delete -n $1 pvc cam-mongo-pv

  echo kubectl delete -n $1 pvc cam-terraform-pv
  kubectl delete -n $1 pvc cam-terraform-pv

  echo kubectl delete -n $1 pvc cam-bpd-appdata-pv
  kubectl delete -n $1 pvc cam-bpd-appdata-pv

  echo kubectl delete pv cam-logs-pv-$1
  kubectl delete pv cam-logs-pv-$1

  echo kubectl delete pv cam-mongo-pv-$1
  kubectl delete pv cam-mongo-pv-$1

  echo kubectl delete pv cam-terraform-pv-$1
  kubectl delete pv cam-terraform-pv-$1

  echo kubectl delete pv cam-bpd-appdata-pv-$1
  kubectl delete pv cam-bpd-appdata-pv-$1
else 
  if [ ! -z $tiller_icp ]; then
    echo helm del cam --purge --tls 
    helm del cam --purge --tls 
  else
    echo helm del cam --purge
    helm del cam --purge
  fi

  echo kubectl -n $1 delete -l release=cam job
  kubectl -n $1 delete -l release=cam job
  echo "Waiting for Pods to terminate"
  kubectl -n $1 get -l release=cam pod
  pods=$(kubectl -n $1 get -l release=cam pods | grep -)
  while [ "${pods}" ]; do
          sleep 2
          kubectl -n $1 get -l release=cam pod
          pods=$(kubectl -n $1 get -l release=cam pods | grep -)
  done
  echo "All pods terminated"

  echo kubectl delete -n $1 pvc cam-logs-pv
  kubectl delete -n $1 pvc cam-logs-pv

  echo kubectl delete -n $1 pvc cam-mongo-pv
  kubectl delete -n $1 pvc cam-mongo-pv

  echo kubectl delete -n $1 pvc cam-terraform-pv
  kubectl delete -n $1 pvc cam-terraform-pv

  echo kubectl delete -n $1 pvc cam-bpd-appdata-pv
  kubectl delete -n $1 pvc cam-bpd-appdata-pv

  echo kubectl delete pv cam-logs-pv
  kubectl delete pv cam-logs-pv

  echo kubectl delete pv cam-mongo-pv
  kubectl delete pv cam-mongo-pv

  echo kubectl delete pv cam-terraform-pv
  kubectl delete pv cam-terraform-pv

  echo kubectl delete pv cam-bpd-appdata-pv
  kubectl delete pv cam-bpd-appdata-pv
fi

echo sleep 15, waiting for things to settle down
sleep 15
