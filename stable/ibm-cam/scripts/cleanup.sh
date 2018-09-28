#!/bin/bash
#
#Licensed Materials - Property of IBM
#5737-E67
#(C) Copyright IBM Corporation 2016, 2017 All Rights Reserved.
#US Government Users Restricted Rights - Use, duplication or
#disclosure restricted by GSA ADP Schedule Contract with IBM Corp.
#
export tiller_version=$(docker images | grep icp | grep tiller | head -1 | awk '{print $2}' | sed 's|v||g')
export tiller_icp=$(echo $tiller_version | awk -F'[.]' '{print $3}' | awk -F'[-]' '{print $2}')

if [ ! -z $tiller_icp ]; then
  echo helm del cam --purge --tls 
  helm del cam --purge --tls 
else
  echo helm del cam --purge
  helm del cam --purge
fi

echo kubectl -n services delete -l release=cam job
kubectl -n services delete -l release=cam job

echo "Waiting for Pods to terminate"
kubectl -n services get -l release=cam pod
pods=$(kubectl -n services get -l release=cam pods | grep -)
while [ "${pods}" ]; do
        sleep 2
        kubectl -n services get -l release=cam pod
        pods=$(kubectl -n services get -l release=cam pods | grep -)
done
echo "All pods terminated"

echo kubectl delete -n services pvc cam-logs-pv
kubectl delete -n services pvc cam-logs-pv

echo kubectl delete -n services pvc cam-mongo-pv
kubectl delete -n services pvc cam-mongo-pv

echo kubectl delete -n services pvc cam-terraform-pv
kubectl delete -n services pvc cam-terraform-pv

echo kubectl delete -n services pvc cam-bpd-appdata-pv
kubectl delete -n services pvc cam-bpd-appdata-pv

echo kubectl delete pv cam-logs-pv
kubectl delete pv cam-logs-pv

echo kubectl delete pv cam-mongo-pv
kubectl delete pv cam-mongo-pv

echo kubectl delete pv cam-terraform-pv
kubectl delete pv cam-terraform-pv

echo kubectl delete pv cam-bpd-appdata-pv
kubectl delete pv cam-bpd-appdata-pv

echo sleep 15, waiting for things to settle down
sleep 15
